# shellcheck shell=sh
# Sourced by update.sh, in a subshell, with the new rootfs mounted at $MNT.

# All 00363-00428 boards have the 5.5" GLT0557201280IS1 panel. U-Boot saves
# its env on first boot, so boards set up before the U-Boot default was fixed
# still boot the base DT, which has no display. Move them to the panel DT.
BASE_DTB=boot/imx93-cargt-00363-00428.dtb
PANEL_DTB=boot/imx93-cargt-00363-00428-glt0557201280is1.dtb
case "$(fw_printenv -n fdtfile 2>/dev/null)" in
	"$BASE_DTB"|"/$BASE_DTB")
		[ -f "$MNT/$PANEL_DTB" ] || fail "$PANEL_DTB missing from new rootfs"
		fw_setenv fdtfile "$PANEL_DTB" || fail "fw_setenv fdtfile $PANEL_DTB failed"
		echo "set fdtfile=${PANEL_DTB}" >> "$LOG"
		;;
esac
