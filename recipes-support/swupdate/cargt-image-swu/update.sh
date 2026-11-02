#!/bin/sh

# swupdate treats a non-zero exit from this postinstall script as a failed
# update. Anything written to stderr is logged by swupdate as an ERROR line
# even when the update succeeds, so keep tools quiet where possible.

LOG=/data/swupdate/log.txt
MNT=/data/swupdate/mnt

# Machine-specific step, installed next to the rootfs tarball by
# sw-description (a no-op unless the machine has its own). It runs in a
# subshell with the new rootfs mounted at $MNT. Remove it on every exit, so
# only the copy installed by this update can ever run.
UPDATE_MACHINE=/data/swupdate/update-machine.sh
trap 'rm -f "$UPDATE_MACHINE"' EXIT
trap 'fail "interrupted"' HUP INT TERM

# Log the failure, unmount the new rootfs if it is mounted, and exit
# non-zero. Inside the machine step's subshell it exits 2, which tells the
# caller the failure is already logged.
fail()
{
	echo "update.sh: $*" >&2
	echo "******Update FAILED: $*********" >> "$LOG"
	umount "$MNT" 2>/dev/null
	exit "${FAIL_STATUS:-1}"
}

get_current_root_device()
{
	read -r CMDLINE < /proc/cmdline
	for i in $CMDLINE; do
		case "$i" in
			root=*) CURRENT_ROOT="${i#root=}";;
		esac
	done

	[ -n "$CURRENT_ROOT" ] || fail "no root= in /proc/cmdline"

	# The A/B swap below needs a device node ending in partition 1 or 2
	case "$CURRENT_ROOT" in
		/dev/*[!0-9][12]) ;;
		*) fail "unsupported root=$CURRENT_ROOT" ;;
	esac

	echo "get_current_root_device=${CURRENT_ROOT}" >> "$LOG"
}

get_update_part()
{
	CURRENT_PART="${CURRENT_ROOT#"${CURRENT_ROOT%?}"}"
	if [ "$CURRENT_PART" = "1" ]; then
		UPDATE_PART="2"
	else
		UPDATE_PART="1"
	fi

	echo "get_current_part=${CURRENT_PART}" >> "$LOG"
	echo "get_update_part=${UPDATE_PART}" >> "$LOG"
}

get_update_device()
{
	UPDATE_ROOT="${CURRENT_ROOT%?}${UPDATE_PART}"
	echo "get_update_device=${UPDATE_ROOT}" >> "$LOG"
}

format_update_device()
{
	umount -q "$UPDATE_ROOT"
	mkfs.ext4 -q -F "$UPDATE_ROOT" || fail "mkfs.ext4 $UPDATE_ROOT failed"
	mkdir -p "$MNT"
	mount "$UPDATE_ROOT" "$MNT" || fail "mount $UPDATE_ROOT failed"

	echo "format_update_device=${UPDATE_ROOT}" >> "$LOG"
}

echo "******Update started*********" >> "$LOG"

# get the current root device
get_current_root_device

# get the device to be updated
get_update_part
get_update_device

# format the device to be updated
format_update_device

echo "tar --zstd -xf /data/swupdate/update.tar.zst -C $MNT" >> "$LOG"
tar --zstd -xf /data/swupdate/update.tar.zst -C "$MNT" || fail "extracting rootfs to $UPDATE_ROOT failed"
# pv /data/swupdate/update.tar.zst | tar --zstd -xf -C /data/swupdate/mnt

if [ -f "$UPDATE_MACHINE" ]; then
	echo "running $UPDATE_MACHINE" >> "$LOG"
	# shellcheck source=/dev/null
	( FAIL_STATUS=2; . "$UPDATE_MACHINE" )
	case $? in
		0) ;;
		2) exit 1 ;;	# fail() in the step logged it and unmounted $MNT
		*) fail "$UPDATE_MACHINE failed" ;;
	esac
fi

# flush the new rootfs to disk before switching the boot partition to it
umount "$MNT" || fail "umount $UPDATE_ROOT failed"

fw_setenv mmcpart "$UPDATE_PART" || fail "fw_setenv mmcpart $UPDATE_PART failed"

echo "******Update complete*********" >> "$LOG"
