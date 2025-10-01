# SPDX-License-Identifier: MIT

HOMEPAGE = "https://www.nxp.com/design/software/development-software/gui-guider:GUI-GUIDER"
DESCRIPTION = "A user-friendly graphical user interface development tool"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=a9b152a21821b0419330795aee9f6602"


FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI = "file://${BPN}.zip;subdir=${BP} \
            file://${BPN}.png \
            "

SRC_URI[md5sum] = "47d1f96c63266c98535efb26defa892b"

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

do_install:append () {

    install -d ${D}/usr/share/weston/icon/
    install -Dm 0644 ${WORKDIR}/${BPN}.png ${D}/usr/share/weston/icon/    
}

FILES:${PN} = "/usr/bin/${BPN} \
                /usr/share/weston/icon/${BPN}.png \
                "

