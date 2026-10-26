#!/bin/sh

# swupdate treats a non-zero exit from this postinstall script as a failed
# update. Anything written to stderr is logged by swupdate as an ERROR line
# even when the update succeeds, so keep tools quiet where possible.

function fail
{
	echo "update.sh: $*" >&2
	echo "******Update FAILED: $*********" >> /data/swupdate/log.txt
	exit 1
}

function get_current_root_device
{
	for i in `cat /proc/cmdline`; do
		if [ ${i:0:5} = "root=" ]; then
			CURRENT_ROOT="${i:5}"
		fi
	done

	[ -n "$CURRENT_ROOT" ] || fail "no root= in /proc/cmdline"

	echo get_current_root_device=${CURRENT_ROOT} >> /data/swupdate/log.txt
}

function get_update_part
{
	CURRENT_PART="${CURRENT_ROOT: -1}"
	if [ $CURRENT_PART = "1" ]; then
		UPDATE_PART="2";
	else
		UPDATE_PART="1";
	fi

	echo get_current_part=${CURRENT_PART} >> /data/swupdate/log.txt
	echo get_update_part=${UPDATE_PART} >> /data/swupdate/log.txt
}

function get_update_device
{
	UPDATE_ROOT=${CURRENT_ROOT%?}${UPDATE_PART}
	echo get_update_device=${UPDATE_ROOT} >> /data/swupdate/log.txt
}

function format_update_device
{
	umount -q $UPDATE_ROOT
	mkfs.ext4 -q -F $UPDATE_ROOT || fail "mkfs.ext4 $UPDATE_ROOT failed"
	mkdir -p /data/swupdate/mnt
	mount $UPDATE_ROOT /data/swupdate/mnt || fail "mount $UPDATE_ROOT failed"

	echo format_update_device=${UPDATE_ROOT} >> /data/swupdate/log.txt
}

echo ******Update started********* >> /data/swupdate/log.txt

# get the current root device
get_current_root_device

# get the device to be updated
get_update_part
get_update_device

# format the device to be updated
format_update_device

echo tar --zstd -xf /data/swupdate/update.tar.zst -C /data/swupdate/mnt >> /data/swupdate/log.txt
tar --zstd -xf /data/swupdate/update.tar.zst -C /data/swupdate/mnt || fail "extracting rootfs to $UPDATE_ROOT failed"
# pv /data/swupdate/update.tar.zst | tar --zstd -xf -C /data/swupdate/mnt

# flush the new rootfs to disk before switching the boot partition to it
umount /data/swupdate/mnt || fail "umount $UPDATE_ROOT failed"

fw_setenv mmcpart $UPDATE_PART || fail "fw_setenv mmcpart $UPDATE_PART failed"

echo ******Update complete********* >> /data/swupdate/log.txt
