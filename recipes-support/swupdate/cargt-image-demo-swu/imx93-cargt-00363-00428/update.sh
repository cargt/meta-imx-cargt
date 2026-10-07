#!/bin/sh

function get_current_root_device
{
	for i in `cat /proc/cmdline`; do
		if [ ${i:0:5} = "root=" ]; then
			CURRENT_ROOT="${i:5}"
		fi
	done

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
	mkfs.ext4 $UPDATE_ROOT -F
	mkdir -p /data/swupdate/mnt
	mount $UPDATE_ROOT /data/swupdate/mnt

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
tar --zstd -xf /data/swupdate/update.tar.zst -C /data/swupdate/mnt 
# pv /data/swupdate/update.tar.zst | tar --zstd -xf -C /data/swupdate/mnt 

# All 00363-00428 boards have the 5.5" GLT0557201280IS1 panel. U-Boot saves
# its env on first boot, so boards set up before the U-Boot default was fixed
# still boot the base DT, which has no display. Move them to the panel DT.
BASE_DTB=boot/imx93-cargt-00363-00428.dtb
PANEL_DTB=boot/imx93-cargt-00363-00428-glt0557201280is1.dtb
case "$(fw_printenv -n fdtfile 2>/dev/null)" in
	$BASE_DTB|/$BASE_DTB)
		if [ -f /data/swupdate/mnt/$PANEL_DTB ]; then
			fw_setenv fdtfile $PANEL_DTB
			echo set fdtfile=${PANEL_DTB} >> /data/swupdate/log.txt
		else
			echo ${PANEL_DTB} missing from new rootfs, fdtfile left unchanged >> /data/swupdate/log.txt
		fi
		;;
esac

fw_setenv mmcpart $UPDATE_PART

echo ******Update complete********* >> /data/swupdate/log.txt
