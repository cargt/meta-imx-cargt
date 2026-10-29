# shellcheck shell=sh
# Machine-specific step for update.sh. This default does nothing.
#
# To add one for a machine, put an update-machine.sh in
# cargt-image-swu/<machine>/ (it replaces this file for that machine), plus
# a copy of cargt-image-swu/sw-description there that also lists it under
# files:, installed to /data/swupdate/update-machine.sh (see
# imx93-cargt-00363-00428/). update.sh sources it, if present, with
# the new rootfs mounted at $MNT, before unmounting it. It runs in a
# subshell: it can use fail(), $MNT and $LOG, and a non-zero exit fails the
# update, but it cannot change update.sh's variables.
