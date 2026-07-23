#!/bin/sh
# Regenerate /etc/fw_env.config to point at the U-Boot environment on
# whichever storage device this system actually booted from.
#
# U-Boot stores its environment at the same offset/size on every boot
# medium (eMMC, SD card, ...), but the device node differs depending on
# which one was actually used to boot. fw_setenv/fw_printenv need to be
# pointed at that same device, or a write from a system booted off SD
# card ends up on the (unbooted) eMMC and is never seen again.
#
# The board-specific offset/size live in /etc/fw-env-geometry.conf.

set -e

GEOMETRY_CONF=/etc/fw-env-geometry.conf
OUT=/etc/fw_env.config

if [ ! -r "$GEOMETRY_CONF" ]; then
	echo "fw-env-config-gen: $GEOMETRY_CONF not found, leaving $OUT untouched" >&2
	exit 0
fi

ENV_OFFSET=""
ENV_SIZE=""
# shellcheck source=/dev/null
. "$GEOMETRY_CONF"

if [ -z "$ENV_OFFSET" ] || [ -z "$ENV_SIZE" ]; then
	echo "fw-env-config-gen: ENV_OFFSET/ENV_SIZE not set in $GEOMETRY_CONF" >&2
	exit 1
fi

root_arg=$(sed -n 's/.*\broot=\(\S*\).*/\1/p' /proc/cmdline)

case "$root_arg" in
/dev/mmcblk*)
	env_dev=$(echo "$root_arg" | sed -E 's#^(/dev/mmcblk[0-9]+)p[0-9]+$#\1#')
	;;
*)
	echo "fw-env-config-gen: unrecognized root= '$root_arg', leaving $OUT untouched" >&2
	exit 0
	;;
esac

cat >"$OUT" <<EOF
# Generated at boot by fw-env-config-gen.sh - do not edit by hand.
# Points fw_setenv/fw_printenv at the U-Boot environment on the device
# this system actually booted from (see $GEOMETRY_CONF for offset/size).
$env_dev	$ENV_OFFSET	$ENV_SIZE
EOF
