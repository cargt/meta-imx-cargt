FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://cargt_router_kernel_config_mods.cfg \
            file://cargt_00363_kernel_config_mods.cfg \
            file://cargt_00365_kernel_config_mods.cfg \
            file://cargt_t1l_kernel_config_mods.cfg \
            file://cargt_st7789t3_kernel_config_mods.cfg \
            "

DELTA_KERNEL_DEFCONFIG += "${@bb.utils.contains('MACHINE_FEATURES', 'cargt-router', 'cargt_router_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00363', 'cargt_00363_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00365', 'cargt_00365_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', 't1l', 'cargt_t1l_kernel_config_mods.cfg','', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', 'ST7789T3', 'cargt_st7789t3_kernel_config_mods.cfg','', d)} \
            "

SRC_URI += "file://0001-Add-device-tree-support-for-00363-and-00365.patch \
            file://0002-Add-support-for-Globaltech-GTC-panels.patch \
            file://0003-Add-support-for-Epson-RX8111-RTC.patch \
            file://0004-Specify-touch-screen-size-for-glt0557201280is1-in-de.patch \
            "