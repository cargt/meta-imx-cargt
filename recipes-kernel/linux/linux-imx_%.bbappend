FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"


SRC_URI += "file://0001-Add-device-tree-support-for-00363-and-00365.patch \
            file://0009-Remove-restriction-for-1.8V-only-SD-Card-support-tha.patch \
            file://0010-Correct-the-MDIO-address-of-ethphy2-due-to-changes-o.patch \
            file://0011-Attach-LPUART5-to-the-Bluetooth-driver-for-00363.patch \
            file://0013-Add-support-for-the-GLT028240320IS1-display-on-the-C.patch \
            file://0019-Add-RTS-CTS-support-for-Bluetooth-UART-on-00363.patch \
            file://0025-Limit-the-maximum-frequency-for-the-SD-Card-to-104-M.patch \
            file://0026-Limit-SD-Card-to-3.3V-only-on-00365-for-compatibilit.patch \
            file://0029-arm64-dts-imx93-cargt-00363-osm-som-Configure-Blueto.patch \
            "

# Re-audited 2026-07-16 while diagnosing "bluetooth doesn't come up on its own":
# 0011/0019/0029 were previously (mis)filed under "other boards/machines" below, but all
# three actually target imx93-cargt-00363-osm-som.dts -- this board's own SOM file, not
# another board. Moved into the active SRC_URI list above (0011 must apply before 0029,
# since 0029's hunk edits the bluetooth{} node that 0011 creates).
#
# Deferred for 00363-00365 kernel bring-up (2026-07-16): driver-only or other-board/machine
# DT patches, not needed to boot this target. Re-enable (move back into SRC_URI above) as
# each area gets picked back up.
#
# Driver-only, not boot-critical:
# file://0002-Add-support-for-Globaltech-GTG-panels.patch
# file://0003-Add-support-for-Epson-RX8111-RTC.patch
# file://0005-Move-ili9881c-panel-initialization-from-the-prepare-.patch
# file://0012-Improve-panel-initialization-error-handling-and-rese.patch
#
# Other boards/machines (00324-00326, 00377, 00359-00406, imx91 variant):
# file://0004-Add-device-tree-files-for-00324-00326.patch
# file://0006-Add-device-tree-files-for-00377.patch
# file://0007-Add-support-for-00359-00406.patch
# file://0008-Make-device-tree-changes-to-allow-00324-to-boot-with.patch
# file://0020-Add-FlexCAN-support-and-update-UART-RTS-CTS-configur.patch
# file://0021-Add-device-tree-support-for-i.MX8MP-00377-OSM-L-SOM-.patch
# file://0022-Reorganize-device-tree-source-file-for-the-Cargt-i.M.patch
# file://0023-Add-device-tree-support-for-OS08A20-camera-and-enabl.patch
# file://0024-Add-HDMI-support-for-Cargt-i.MX8MP-00377-OSM-L-SOM-o.patch
# file://0027-arm64-dts-imx91-Add-CARGT-00363-OSM-L-SOM-and-00365-.patch
# file://0028-arm64-dts-imx91-Update-shared-DMA-pool-configuration.patch
# file://0030-Add-support-for-second-RS-232-UART-lpuart7-in-device.patch

# DELTA_KERNEL_DEFCONFIG is deprecated/unsupported as of wrynose meta-imx-bsp;
# per-machine selection is now done by conditionally adding each .cfg to
# SRC_URI directly. kernel-yocto auto-merges any .cfg fragment found there.
SRC_URI += "${@bb.utils.contains('MACHINE_FEATURES', 'cargt-router', 'file://cargt_router_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00324', 'file://cargt_00324_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00326', 'file://cargt_00326_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00359', 'file://cargt_00359_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00363', 'file://cargt_00363_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00365', 'file://cargt_00365_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00377', 'file://cargt_00377_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', '00406', 'file://cargt_00406_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', 't1l', 'file://cargt_t1l_kernel_config_mods.cfg', '', d)} \
            ${@bb.utils.contains('MACHINE_FEATURES', 'ST7789T3', 'file://cargt_st7789t3_kernel_config_mods.cfg', '', d)} \
            "