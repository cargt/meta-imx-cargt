#!/bin/bash
DATAPARTINIT=$( lsblk | grep 128M )
DATAPART=$( lsblk | grep data )

if [ -z "$DATAPARTINIT" ]; then
	echo "Data partition: ${DATAPART}"
else
	echo "Resizing data partition to fill eMMC"	
    /bin/umount -l /data
	/usr/sbin/parted --script /dev/mmcblk2 resizepart 4 100%
    /bin/mount /dev/mmcblk2p4 /data
	/lib/systemd/systemd-growfs /data    
    /sbin/reboot
	echo "data resize complete"
fi







