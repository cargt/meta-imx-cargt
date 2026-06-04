FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"


SRC_URI += "file://0001-Add-device-tree-support-for-00363-and-00365.patch \
            file://0002-Add-support-for-Globaltech-GTG-panels.patch \
            file://0003-Add-support-for-Epson-RX8111-RTC.patch \
            file://0004-Add-device-tree-files-for-00324-00326.patch \
            file://0005-Move-ili9881c-panel-initialization-from-the-prepare-.patch \
            file://0006-Add-device-tree-files-for-00377.patch \
            file://0007-Add-support-for-00359-00406.patch \
            file://0008-Make-device-tree-changes-to-allow-00324-to-boot-with.patch \
            file://0009-Remove-restriction-for-1.8V-only-SD-Card-support-tha.patch \
            file://0010-Correct-the-MDIO-address-of-ethphy2-due-to-changes-o.patch \
            file://0011-Attach-LPUART5-to-the-Bluetooth-driver-for-00363.patch \
            file://0012-Improve-panel-initialization-error-handling-and-rese.patch \
            file://0013-Add-support-for-the-GLT028240320IS1-display-on-the-C.patch \
            file://0019-Add-RTS-CTS-support-for-Bluetooth-UART-on-00363.patch \
            file://0020-Add-FlexCAN-support-and-update-UART-RTS-CTS-configur.patch \
            file://0021-Add-device-tree-support-for-i.MX8MP-00377-OSM-L-SOM-.patch \
            file://0022-Reorganize-device-tree-source-file-for-the-Cargt-i.M.patch \
            file://0023-Add-device-tree-support-for-OS08A20-camera-and-enabl.patch \
            file://0024-Add-HDMI-support-for-Cargt-i.MX8MP-00377-OSM-L-SOM-o.patch \
            file://0025-Limit-the-maximum-frequency-for-the-SD-Card-to-104-M.patch \
            file://0026-Limit-SD-Card-to-3.3V-only-on-00365-for-compatibilit.patch \
            file://0027-arm64-dts-imx91-Add-CARGT-00363-OSM-L-SOM-and-00365-.patch \
            file://0028-arm64-dts-imx91-Update-shared-DMA-pool-configuration.patch \
            file://0029-arm64-dts-imx93-cargt-00363-osm-som-Configure-Blueto.patch \
            "

SRC_URI += "file://cargt_router_kernel_config_mods.cfg \
            file://cargt_00324_kernel_config_mods.cfg \
            file://cargt_00326_kernel_config_mods.cfg \
            file://cargt_00359_kernel_config_mods.cfg \
            file://cargt_00363_kernel_config_mods.cfg \
            file://cargt_00365_kernel_config_mods.cfg \
            file://cargt_00377_kernel_config_mods.cfg \
            file://cargt_00406_kernel_config_mods.cfg \
            file://cargt_t1l_kernel_config_mods.cfg \
            file://cargt_st7789t3_kernel_config_mods.cfg \
            "

DELTA_KERNEL_DEFCONFIG += "${@bb.utils.contains('MACHINE_FEATURES', 'cargt-router', 'cargt_router_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00324', 'cargt_00324_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00326', 'cargt_00326_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00359', 'cargt_00359_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00363', 'cargt_00363_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00365', 'cargt_00365_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00377', 'cargt_00377_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00406', 'cargt_00406_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', 't1l', 'cargt_t1l_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', 'ST7789T3', 'cargt_st7789t3_kernel_config_mods.cfg','', d)} \
            "