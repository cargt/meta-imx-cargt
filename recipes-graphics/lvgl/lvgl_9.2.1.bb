# SPDX-License-Identifier: MIT

HOMEPAGE = "https://lvgl.io/"
DESCRIPTION = "LVGL is an OSS graphics library to create embedded GUI"
SUMMARY = "Light and Versatile Graphics Library"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bf1198c89ae87f043108cea62460b03a"

include lvgl.inc

SRC_URI = "file://lvgl.zip;subdir=${BP} \
    file://lv_conf.h;subdir=${BP} \
    file://lv_conf_ext.h;subdir=${BP} \
"

DEPENDS = "libxkbcommon wayland libdrm wayland-native"

REQUIRED_DISTRO_FEATURES = "wayland"

inherit cmake
inherit features_check
inherit pkgconfig

EXTRA_OECMAKE = "\
    -DLIB_INSTALL_DIR=${BASELIB} \
    -DLV_CONF_BUILD_DISABLE_EXAMPLES=1 \
    -DLV_CONF_BUILD_DISABLE_DEMOS=1 \
    -DLV_CONF_BUILD_DISABLE_THORVG_INTERNAL=1 \
"

TARGET_CFLAGS += "-I${S}/wl_protocols -I${RECIPE_SYSROOT}/${includedir}/drm"

do_generate_protocols() {
    cd ${S}/wl_protocols
    cmake .
    make
}
addtask generate_protocols before do_configure after do_prepare_recipe_sysroot

do_install:append() {
    install -m 0644 ${S}/lv_conf_ext.h ${D}${includedir}/${PN}/
}

FILES:${PN}-dev += "\
    ${includedir}/${PN}/ \
    ${includedir}/${PN}/lvgl/ \
    "
