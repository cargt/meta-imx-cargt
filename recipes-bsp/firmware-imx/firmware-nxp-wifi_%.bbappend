# Use the latest revision

# LIC_FILES_CHKSUM intentionally not set here (2026-07-16): the official
# meta-imx/meta-imx-bsp firmware-nxp-wifi_%.bbappend already declares the
# correct current checksum (md5=bc649096ad3928ec06a8713b8d787eac, matching
# the LA_OPT_NXP_Software_License v63 May 2025 text) for the exact same
# LICENSE.txt. Cargt's own copy here was stale (from an older license
# version) and overrode it, causing a license-checksum QA failure.

IMX_FIRMWARE_SRC ?= "git://github.com/nxp-imx/imx-firmware.git;protocol=https"
SRC_URI = "${IMX_FIRMWARE_SRC};branch=${SRCBRANCH}"
SRCBRANCH = "lf-6.18.20_2.0.0"
SRCREV = "${AUTOREV}"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# 0001-FwImage-update-firmware-to-mxm18505.p14.patch (a binary firmware blob
# bump, not code) removed 2026-07-16: it targeted an old nxp/FwImage_*
# directory layout that no longer exists in lf-6.18.20_2.0.0 (FwImage_* now
# lives at the repo root, no nxp/ wrapper), and this branch is a much newer
# firmware release than the patch targeted — almost certainly already at or
# past mxm18505.p14. Custom do_patch() dropped along with it; default
# patch.bbclass behavior is sufficient with no patches left in SRC_URI.

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/nxp
    oe_runmake install INSTALLDIR=${D}${nonarch_base_libdir}/firmware/nxp
}

FILES:${PN}-nxp9098-common = " \
    ${nonarch_base_libdir}/firmware/nxp/ed_mac_ctrl_V3_909x.conf \
    ${nonarch_base_libdir}/firmware/nxp/txpwrlimit_cfg_9098.conf \
    ${nonarch_base_libdir}/firmware/nxp/uart9098_bt_v1.bin \
"

FILES:${PN}-nxp9098-sdio = " \
    ${nonarch_base_libdir}/firmware/nxp/sd*9098* \
"

# IW610 support (always available - firmware installed via oe_runmake)
FILES:${PN}-nxpiw610-sdio = " \
    ${nonarch_base_libdir}/firmware/nxp/sd_iw610.bin.se \
    ${nonarch_base_libdir}/firmware/nxp/sduart_iw610.bin.se \
    ${nonarch_base_libdir}/firmware/nxp/sduartspi_iw610.bin.se \
    ${nonarch_base_libdir}/firmware/nxp/uart_iw610_bt.bin.se \
    ${nonarch_base_libdir}/firmware/nxp/uartspi_iw610.bin.se \
"

FILES:${PN}-nxpiw612-sdio += " \
    ${nonarch_base_libdir}/firmware/nxp/uartuart_n61x_v1.bin.se \
"

# Note: PACKAGES/FILES/RDEPENDS for nxpaw693-sdio (new AW693 SDIO firmware in
# lf-6.18.20_2.0.0) are already provided by the official
# meta-imx/meta-imx-bsp/recipes-bsp/firmware-imx/firmware-nxp-wifi_%.bbappend
# (which also already removes the bogus nxp8997-sdio, confirming that fix was
# correct). Don't duplicate it here — caused a "listed in PACKAGES multiple
# times" QA error the first time (2026-07-16).

RDEPENDS:${PN}-all-sdio = " \
    ${PN}-nxp8987-sdio \
    ${PN}-nxp9098-sdio \
    ${PN}-nxpiw416-sdio \
    ${PN}-nxpiw610-sdio \
    ${PN}-nxpiw612-sdio \
    ${PN}-nxpaw693-sdio \
"

RDEPENDS:${PN}-all-pcie = " \
    ${PN}-nxp9098-pcie \
    ${PN}-nxpaw693-pcie \
"

ALLOW_EMPTY:${PN}-all-sdio = "1"
ALLOW_EMPTY:${PN}-all-pcie = "1"
