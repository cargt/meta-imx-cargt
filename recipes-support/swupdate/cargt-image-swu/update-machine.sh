# shellcheck shell=sh
# Machine-specific step for update.sh. This default does nothing.
#
# To add one for a machine, put an update-machine.sh in
# cargt-image-swu/<machine>/ (it replaces this file for that machine, see
# imx93-cargt-00363-00428/). sw-description installs it to
# /data/swupdate/update-machine.sh for every machine, and update.sh sources
# it with the new rootfs mounted at $MNT, before unmounting it. It runs in a
# subshell: it can use fail(), $MNT and $LOG, and a non-zero exit fails the
# update, but it cannot change update.sh's variables.
