#!/bin/sh
# Mount the partition labelled "data" on the boot disk at /data, first growing
# it to the end of that disk (and its ext4 filesystem online) when it is the
# last partition. Runs at every boot; the grow does nothing once the partition
# already fills the disk.
#
# The boot disk is the one holding root= (eMMC or SD card, whichever the boot
# switches selected), so a second disk with its own "data" partition, such as
# an SD card with a Cargt image in an eMMC-booted board, is never used. This
# is why /data is not in fstab: LABEL=data matches both.
#
# Assumes the layout from cargt-dev.wks.in (MBR: rootfs A, rootfs B, data).
set -eu

log() { echo "grow-data-part: $*"; }

root=$(sed -n 's/.*\broot=\([^ ]*\).*/\1/p' /proc/cmdline)
case "$root" in
	/dev/*) ;;
	*) root=$(findfs "$root" 2>/dev/null || true) ;;
esac
[ -b "${root:-}" ] || { log "boot device not found (root=$root), nothing to do"; exit 0; }

disk=/dev/$(lsblk -n -o PKNAME "$root" | head -n1)

# Nothing in fstab waits for the data partition, so this can start before
# udev has probed it: wait for udev, then give the label a few seconds.
udevadm settle --timeout=30 || true
tries=10
while :; do
	part=$(lsblk -n -p -r -o NAME,LABEL "$disk" | awk '$2 == "data" { print $1; exit }')
	[ -z "$part" ] || break
	tries=$((tries - 1))
	[ "$tries" -gt 0 ] || { log "no partition labelled data on $disk"; exit 0; }
	sleep 1
done

grow() {
	last=$(lsblk -n -p -r -o NAME,TYPE "$disk" | awk '$2 == "part" { p = $1 } END { print p }')
	[ "$part" = "$last" ] || { log "$part is not the last partition on $disk, not growing it"; return 0; }

	p=$(basename "$part"); d=$(basename "$disk")
	num=$(cat /sys/class/block/$p/partition)
	start=$(cat /sys/class/block/$p/start)
	size=$(cat /sys/class/block/$p/size)
	total=$(cat /sys/class/block/$d/size)
	free=$((total - start - size))

	# Less than 16 MiB left: treat as already grown (alignment slack).
	[ "$free" -ge 32768 ] || return 0

	log "growing $part (partition $num) by $((free / 2048)) MiB to the end of $disk"
	echo ",+" | sfdisk --quiet --no-reread --no-tell-kernel -N "$num" "$disk"
	partx -u -n "$num" "$disk"
	resize2fs "$part"
	log "grown to $(( $(cat /sys/class/block/$p/size) / 2048 )) MiB"
}

grow

# Mount it on /data. udev may also auto-mount it under /run/media; mounting
# the same filesystem twice is fine, but while udev's mount is in progress the
# device is held exclusively and mount fails with "Can't open blockdev", so
# retry for a few seconds.
if mountpoint -q /data; then
	cur=$(findmnt -n -o SOURCE /data)
	[ "$(readlink -f "$cur")" = "$part" ] && exit 0
	log "/data is $cur, not $part on the boot disk; remounting"
	umount /data
fi
mkdir -p /data
tries=10
until mount -t ext4 "$part" /data; do
	tries=$((tries - 1))
	[ "$tries" -gt 0 ] || { log "could not mount $part on /data"; exit 1; }
	sleep 1
done
log "mounted $part on /data"
