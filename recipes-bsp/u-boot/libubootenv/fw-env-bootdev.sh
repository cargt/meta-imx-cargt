#!/bin/sh
# U-Boot keeps its environment on the MMC device it booted from, so point
# fw_env.config at the device holding the root partition (root=/dev/mmcblkNpM)
# instead of a fixed mmcblkN. /etc/fw_env.config is a symlink to the file
# written here; the machine's shipped config is the template.

TEMPLATE=/etc/fw_env.config.default
OUT=/run/fw_env.config

dev=
for arg in $(cat /proc/cmdline); do
	case "$arg" in
	root=/dev/mmcblk*p*)
		dev="${arg#root=}"
		dev="${dev%p*}"
		;;
	esac
done

if [ -n "$dev" ]; then
	sed "s|^/dev/mmcblk[0-9]*|$dev|" "$TEMPLATE" > "$OUT"
else
	cp "$TEMPLATE" "$OUT"
fi
