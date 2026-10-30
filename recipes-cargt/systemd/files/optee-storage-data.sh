#!/bin/sh
# tee-supplicant wrapper: keep REE FS secure storage on /data/tee, unless the
# rootfs is on the network (NFS root during development). Then grow-data-part
# does not mount /data, so use tee-supplicant's default /var/lib/tee instead.
#
# This runs very early (before sysinit.target), as teesuppl, so it cannot wait
# for /data or probe partitions. It does not need to: the image only installs
# this on machines whose WKS has the data partition, and on a block-device
# rootfs /data is mounted later by grow-data-part. A request before then fails
# and is retried (see optee-storage-data.conf).
case "$(awk '$2 == "/" { t = $3 } END { print t }' /proc/mounts)" in
nfs | nfs4 | cifs | smb3)
	exec /usr/sbin/tee-supplicant "$@"
	;;
esac
exec /usr/sbin/tee-supplicant --fs-parent-path=/data/tee "$@"
