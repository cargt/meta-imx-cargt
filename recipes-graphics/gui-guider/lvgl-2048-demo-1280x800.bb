# SPDX-License-Identifier: MIT

HOMEPAGE = "https://www.nxp.com/design/software/development-software/gui-guider:GUI-GUIDER"
DESCRIPTION = "A user-friendly graphical user interface development tool"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=a9b152a21821b0419330795aee9f6602"


SRC_URI = "file://${BPN}.zip;subdir=${BP}"
SRC_URI[md5sum] = "b995c7ddf325466271095d1f0dbb35e5"

REQUIRED_DISTRO_FEATURES = "wayland"

DEPENDS = " \
    libxkbcommon \
    lvgl \
    wayland \
    libdrm \
    wayland-native \
    ${@bb.utils.contains('GG_FEATURES', 'video', 'openh264', '', d)} \
    ${@bb.utils.contains('GG_FEATURES', 'camera', 'opencv', '', d)} \
"

inherit cmake
inherit features_check
inherit pkgconfig

TARGET_CFLAGS += "-I${RECIPE_SYSROOT}/${includedir}/lvgl"
TARGET_CFLAGS += "-I${RECIPE_SYSROOT}/${includedir}/lvgl/src"

