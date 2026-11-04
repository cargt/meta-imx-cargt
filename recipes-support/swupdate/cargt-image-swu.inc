# Common part of the cargt-image-*-swu recipes. Each recipe sets
# CARGT_SWU_IMAGE to the image it packs and requires this file.
#
# cargt-image-swu/ holds the files shared by every image and machine:
# sw-description (a template, keyed by @@MACHINE@@), update.sh and a no-op
# update-machine.sh, which sw-description installs and update.sh sources. A
# machine that needs an extra update step overrides update-machine.sh in
# cargt-image-swu/<machine>/.

DESCRIPTION = "swupdate file for ${CARGT_SWU_IMAGE}"
SECTION = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/cargt-image-swu:"

# Note: sw-description is mandatory
SRC_URI = " \
	file://sw-description \
	file://update.sh \
	file://update-machine.sh \
"

inherit swupdate

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = "${CARGT_SWU_IMAGE}"

# The rootfs file in DEPLOY_DIR_IMAGE that goes into the .swu.
# sw-description names it as @@CARGT_SWU_ROOTFS@@.
CARGT_SWU_ROOTFS = "${CARGT_SWU_IMAGE}${IMAGE_MACHINE_SUFFIX}.rootfs.tar.zst"

# SWUPDATE_IMAGES: list of images that will be part of the compound image
# the list can have any binaries - images must be in the DEPLOY directory.
# A full file name needs no SWUPDATE_IMAGES_FSTYPES flag.
SWUPDATE_IMAGES = "${CARGT_SWU_ROOTFS}"

# The A/B update needs the Cargt rootfs layout (cargt-dev.wks.in). The
# NXP-layout FRDMs have a FAT boot partition on p1, which update.sh would
# format, so build only for the Cargt machines and the A/B-layout FRDMs.
COMPATIBLE_MACHINE = "(.*-cargt-.*|imx95-15x15-lpddr4x-frdm|imx95-19x19-lpddr5-frdm-pro)"
