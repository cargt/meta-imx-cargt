FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0002-Add-support-for-imx93_00363.patch \
            file://0003-Update-u-boot-imx-to-boot-Cargt-Linux-image.patch \
            file://0004-Add-support-for-Cargt-00324-00326-SODIMM-SOM-on-carr.patch \
            file://0005-Autosave-env-when-defaults-are-set.patch \
            file://0001-WIP-Initial-check-in-for-00377-support.patch \
            file://0001-WIP-Update-device-tree-for-00377-00365.patch \
            file://0001-WIP-Update-00377-configs.patch \
            file://0001-Update-target-in-00377-defconfig.patch \
            file://0001-WIP-Add-config-for-00377.patch \
            file://0001-Add-TARGET_IMX8MP_00377-stanza-to-the-imx8m-Kconfig.patch \
            file://0001-WIP-Changes-for-00377-bring-up.patch \
            file://0001-WIP-Do-not-include-security-definitions-for-00377.patch \
            file://0001-WIP-Assign-all-resources-to-the-application-processo.patch \
            file://0002-WIP-REMOVE-Add-debug-printing.patch \
            file://0001-WIP-Update-settings-for-proper-UART-in-U-Boot-for-00.patch \
            file://0001-WIP-Fix-dtb-specification-for-U-Boot-for-00377.patch \
            "

SRC_URI:remove:imx8mp-cargt-00377-00365 = "file://0001-Add-Olimex-iMX8MP-SOM-EVB-IND.patch"
