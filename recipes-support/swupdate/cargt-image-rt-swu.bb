DESCRIPTION = "swupdate file for cargt-image-rt"
SECTION = ""

# Note: sw-description is mandatory
SRC_URI = " \
	file://sw-description \
	file://update.sh \
"

inherit swupdate

# sw-description/update.sh only exist for these machines (see cargt-image-rt-swu/)
COMPATIBLE_MACHINE = "(imx95-cargt-00414-.*|imx95-15x15-lpddr4x-frdm)"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = "cargt-image-rt"

# SWUPDATE_IMAGES: list of images that will be part of the compound image
# the list can have any binaries - images must be in the DEPLOY directory
SWUPDATE_IMAGES = " \
	cargt-image-rt \
"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
SWUPDATE_IMAGES_FSTYPES[cargt-image-rt] = '.rootfs.tar.zst'
