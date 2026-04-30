FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0002-Add-support-for-imx93_00363.patch \
            file://0003-Update-u-boot-imx-to-boot-Cargt-Linux-image.patch \
            file://0004-Add-support-for-Cargt-00324-00326-SODIMM-SOM-on-carr.patch \
            file://0005-Autosave-env-when-defaults-are-set.patch \
            file://0006-Add-support-for-00377-00365.patch \
            file://0007-Update-MDIO-addresses-for-Ethernet-PHYs-on-00365-boa.patch \
            file://0008-Refactor-PCA9555-GPIO-configuration-and-update-USB-C.patch \
            file://0009-Add-support-for-loading-DDR-timing-from-EEPROM-for-C.patch \
            file://0010-Add-support-for-00359-00406.patch \
            file://0011-Update-defconfig-settings-for-DDR-selection-for-0032.patch \
            file://0012-Fix-preprocessor-definition-typo.patch \
            file://0013-Add-Cargt-EEPROM-support-for-LPDDR4-timing-configura.patch \
            file://0014-Update-USB-role-switch-mode-and-add-USB-port-auto-co.patch \
            file://0015-Add-USB-DWC3-gadget-support-and-remove-redundant-com.patch \
            "

SRC_URI:remove = "file://0001-Add-Olimex-iMX8MP-SOM-EVB-IND.patch"
