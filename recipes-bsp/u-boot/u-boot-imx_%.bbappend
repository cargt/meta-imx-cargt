# uboot-config.bbclass computes KCONFIG_CONFIG_ROOTDIR before externalsrc updates B.
# Re-apply it here at the end of parsing using a lazy ${B} path so devtool builds
# look in ${WORKDIR}/u-boot-imx-*/<defconfig> instead of ${WORKDIR}/build/<defconfig>.
python () {
    um = (d.getVar('UBOOT_MACHINE') or '').strip()
    if um:
        import os
        d.setVar('KCONFIG_CONFIG_ROOTDIR', os.path.join('${B}', um))
}

do_configure:prepend() {
    # Standalone device tree source files, extracted out of the numbered
    # patches below so they get real git history/diffs instead of being
    # buried in patch hunks -- see recipes-bsp/u-boot/u-boot-imx/files/dts/.
    # do_patch's do_patch task is a python task here (generic patch.bbclass,
    # not the kernel's shell-based do_patch override), so this copy is done
    # in do_configure:prepend instead of do_patch:append.
    if [ -d "${UNPACKDIR}/dts" ]; then
        cp -a ${UNPACKDIR}/dts/. ${S}/arch/arm/dts/
    fi
    if [ -f "${S}/.config" ]; then
        cp "${S}/.config" "${B}/.config"
    fi
}

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/files:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://dts/imx8mp-cargt-00377-00365.dts \
            file://dts/imx8mp-cargt-00377-00365-u-boot.dtsi \
            file://dts/imx8mp-cargt-00377-osm-som.dts \
            file://dts/imx93-cargt-00363-00365.dts \
            file://dts/imx93-cargt-00363-00365-u-boot.dtsi \
            file://dts/imx93-cargt-00363-osm-som.dts \
            file://dts/imx93-cargt-00363-osm-som-u-boot.dtsi \
            file://dts/imx93-cargt-00324-00326.dts \
            file://dts/imx93-cargt-00324-00326-u-boot.dtsi \
            file://dts/imx93-cargt-00359-00406.dts \
            file://dts/imx93-cargt-00359-00406-u-boot.dtsi \
            file://dts/imx93-cargt-00359.dts \
            file://dts/imx91-cargt-00363-00365.dts \
            file://dts/imx91-cargt-00363-00365-u-boot.dtsi \
            file://dts/imx91-cargt-00363-osm-som.dts \
            file://dts/imx91-cargt-00363-osm-som-u-boot.dtsi \
            "

SRC_URI += "file://0001-arch-arm-dts-register-Cargt-board-dtb-y-entries.patch \
            file://0002-Add-support-for-imx93_00363.patch \
            file://0003-Update-u-boot-imx-to-boot-Cargt-Linux-image.patch \
            file://0004-Add-support-for-Cargt-00324-00326-SODIMM-SOM-on-carr.patch \
            file://0005-Autosave-env-when-defaults-are-set.patch \
            file://0006-Add-support-for-00377-00365.patch \
            file://0007-Add-support-for-loading-DDR-timing-from-EEPROM-for-C.patch \
            file://0008-Add-support-for-00359-00406.patch \
            file://0009-Update-defconfig-settings-for-DDR-selection-for-0032.patch \
            file://0010-Fix-preprocessor-definition-typo.patch \
            file://0011-Add-Cargt-EEPROM-support-for-LPDDR4-timing-configura.patch \
            file://0012-Update-USB-role-switch-mode-and-add-USB-port-auto-co.patch \
            file://0013-Add-USB-DWC3-gadget-support-and-remove-redundant-com.patch \
            file://0014-Add-common-LPDDR4X-timing-support-and-update-configurations.patch \
            file://0015-cargt-EEPROM-v2-dram_rank-support-and-generated-rank.patch \
            file://0016-ddr-imx-add-training-diagnostics-PMU-messages-DDRPHY.patch \
            file://0017-tools-add-LPDDR4X-timing-validation-scripts.patch \
            file://0018-cargt-imx93_00363-512MB-timing-variants-rank-2-overr.patch \
            file://0019-cargt-imx93_00363-LPDDR4X-shared-timing-infra-all-va.patch \
            file://0020-board-cargt-add-i.MX-91-00363-OSM-L-SOM-board-suppor.patch \
            file://0021-imx93-cargt-Share-LPDDR4X-timing-files-across-all-i.patch \
            file://0022-configs-disable-HS400-support-in-i.MX93-Cargt-U-Boot.patch \
            file://0023-Modify-Serial-Number-output-to-be-decimal-as-well-as.patch \
            file://0024-ddr-imx9-bound-DYN_REF-mode-register-polls-with-a-t.patch \
            file://0025-board-cargt-imx8mp_00377-fix-I2C2-USB-C-bring-up-bug.patch \
            file://0026-configs-imx8mp_00377-remove-hardcoded-FEC-PHY-addres.patch \
            file://0027-board-cargt-common-add-EEPROM-dram_rank-write-repair.patch \
            file://0028-board-cargt-imx8mp_00377-vendor-neutral-DDR-dispatch.patch \
            file://0029-configs-imx8mp_00377-set-explicit-SYS_MALLOC_F_LEN.patch \
            "
