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
part=$(lsblk -n -p -r -o NAME,LABEL "$disk" | awk '$2 == "data" { print $1; exit }')
[ -n "$part" ] || { log "no partition labelled data on $disk"; exit 0; }

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

# Mount it on /data. udev may also have auto-mounted it under /run/media;
# mounting the same filesystem twice is fine.
if mountpoint -q /data; then
	cur=$(findmnt -n -o SOURCE /data)
	[ "$(readlink -f "$cur")" = "$part" ] && exit 0
	log "/data is $cur, not $part on the boot disk; remounting"
	umount /data
fi
mkdir -p /data
mount -t ext4 "$part" /data
log "mounted $part on /data"
