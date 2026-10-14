#!/bin/sh
# Grow the partition labelled "data" on the boot disk to the end of that disk,
# then grow its ext4 filesystem online. Runs at every boot and does nothing
# once the partition already fills the disk. No unmount or reboot is needed.
#
# Assumes the layout from cargt-dev.wks.in (MBR: rootfs A, rootfs B, data),
# where "data" is the last partition. Anything else is left untouched.
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

last=$(lsblk -n -p -r -o NAME,TYPE "$disk" | awk '$2 == "part" { p = $1 } END { print p }')
[ "$part" = "$last" ] || { log "$part is not the last partition on $disk, leaving it"; exit 0; }

p=$(basename "$part"); d=$(basename "$disk")
num=$(cat /sys/class/block/$p/partition)
start=$(cat /sys/class/block/$p/start)
size=$(cat /sys/class/block/$p/size)
total=$(cat /sys/class/block/$d/size)
free=$((total - start - size))

# Less than 16 MiB left: treat as already grown (alignment slack).
[ "$free" -ge 32768 ] || exit 0

log "growing $part (partition $num) by $((free / 2048)) MiB to the end of $disk"
echo ",+" | sfdisk --quiet --no-reread --no-tell-kernel -N "$num" "$disk"
partx -u -n "$num" "$disk"
resize2fs "$part"
log "done: $(( $(cat /sys/class/block/$p/size) / 2048 )) MiB"
