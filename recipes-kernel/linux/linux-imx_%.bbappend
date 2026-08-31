FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"


SRC_URI += "file://0001-Add-device-tree-support-for-00363-and-00365.patch \
            file://0002-Add-support-for-Globaltech-GTG-panels.patch \
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
            file://0030-Add-support-for-second-RS-232-UART-lpuart7-in-device.patch \
            file://0031-serial-imx-fall-back-to-PIO-RX-if-DMA-prep-fails.patch \
            file://0032-dma-imx-sdma-restore-runtime-PM-wake-before-per-op-c.patch \
            file://0033-serial-imx-revert-TXTL_DEFAULT-to-2-test.patch \
            file://0034-drm-bridge-sec-dsim-config-esc-byte-clock-before-pa.patch \
            "

# Re-audited 2026-07-16 while diagnosing "bluetooth doesn't come up on its own":
# 0011/0019/0029 were previously (mis)filed under "other boards/machines", but all three
# actually target imx93-cargt-00363-osm-som.dts -- this board's own SOM file, not another
# board.
#
# Re-audited again (2026-07-16): 0002 adds the "globaltech,glt0557201280is1" ili9881c panel
# variant that this board's own imx93-cargt-00363-00365-glt0557201280is1.dtsi actually uses.
# 0005/0012 are generic ili9881c.c prepare/unprepare/enable refinements layered on top of
# 0002's additions, not board-specific.
#
# 0003-Add-support-for-Epson-RX8111-RTC.patch: NOT re-enabled, deleted as obsolete --
# drivers/rtc/rtc-rx8111.c plus its Kconfig/Makefile entries are already upstream in the
# wrynose kernel tree (confirmed via kernel-source inspection and a live boot: "rtc-rx8111
# 0-0032: registered as rtc0" using only patch 0001's existing rtc_i2c DT node + this
# board's cargt_00363_kernel_config_mods.cfg CONFIG_RTC_DRV_RX8111=y, no patch needed).
#
# 2026-07-17: user has hardware to bring up the remaining boards too (00324-00326,
# 00359-00406, imx91 variant of 00363-00365, imx8mp-00377), so the rest of the original
# 0001-0030 scarthgap patch series is now active as well, restored to the exact original
# numeric order those patches were written/tested against. Correction: DTBs do NOT all
# compile together regardless of MACHINE -- each machine's .conf sets its own
# KERNEL_DEVICETREE list, which scopes exactly which .dtb files a given MACHINE-scoped
# do_compile actually attempts. Applying all patches here is still safe because do_patch
# applies to the whole linux-imx source tree (not per-machine), and each board's dts/dtsi
# content is only pulled in via that board's own #include chain -- but a real
# MACHINE=<other-board> build is required to actually validate a board's DTBs, not just a
# 00363-00365 build with the patch present. All four other boards (00324-00326,
# 00359-00406, imx91-cargt-00363-00365, imx8mp-cargt-00377-00365) have now been verified
# this way via real per-machine `bitbake linux-imx -c compile -f` runs with
# MACHINE set directly in local.conf (exporting MACHINE in the shell does NOT work --
# local.conf's `MACHINE ??= ...` wins since BB_ENV_PASSTHROUGH_ADDITIONS is not configured
# for this build).
#
# Fixes required along the way (upstream kernel restructuring between scarthgap/lf-6.6.y
# and wrynose/lf-6.18.y, not bugs in our patches):
#  - imx91: mu1/mu2 mailbox nodes were removed from imx91.dtsi entirely -- dropped the
#    &mu1/&mu2 status="okay" overrides from patch 0027's osm-som.dts.
#  - imx8mp: gpu_3d/gpu_2d/ml_vipsi labels were renamed to gpu3d/gpu2d/npu in imx8mp.dtsi
#    (patches 0006, 0023). hdmi_pavi/hdmi/hdmiphy moved out of imx8mp.dtsi into an optional
#    imx8mp-nxp-display.dtsi overlay (which also replaces lcdif1/lcdif2/lcdif3/mipi_dsi/
#    lvds_bridge with NXP's downstream driver-stack versions) -- added
#    #include "imx8mp-nxp-display.dtsi" to imx8mp-cargt-00377-00365.dtsi (patch 0022), which
#    required deleting the overlay's default mipi_dsi "port" node (/delete-node/ port;) to
#    avoid a duplicate-label conflict with our own port@0/port@1 DSI panel wiring (patch
#    0006). Also fixed a real hunk-header/line-count bug introduced while making that edit
#    (declared @@ -0,0 +1,118 @@ after adding 2 lines, silently truncating the file and
#    dropping the closing brace for &mipi_dsi -- always recount when hand-editing a
#    "new file" hunk). The camera "cameradev" wrapper node was removed and isi_1 was
#    consolidated away (isi_0 now handles both CSI ports) -- dropped the &cameradev and
#    &isi_1 overrides from patch 0023's os08a20.dtsi and moved status="okay" directly onto
#    &isi_0.
#
# The imx8mp-00377 patches (0006, 0020-0024) in particular are a strict sequential chain --
# 0006 creates the base files, 0020/0021 modify them, 0022 reorganizes into new .dtsi files,
# 0023/0024 build on that reorganization -- do not reorder relative to each other.

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