FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/files:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# Standalone device tree source files, extracted out of the numbered patches
# below so they get real git history/diffs instead of being buried in patch
# hunks. Installed into the kernel source tree after all patches have applied
# (do_patch:append, below) -- see recipes-kernel/linux/linux-imx/files/dts/.
SRC_URI += " \
            file://dts/freescale/imx93-cargt-00359-00406.dts \
            file://dts/freescale/imx93-cargt-00359.dts \
            file://dts/freescale/imx93-cargt-00324-00326.dts \
            file://dts/freescale/imx93-cargt-00324-00326-00375.dts \
            file://dts/freescale/imx93-cargt-00324-00326-glt0701024600is2.dts \
            file://dts/freescale/imx93-cargt-00324-00326-glt0701024600is2.dtsi \
            file://dts/freescale/imx93-cargt-00324-00326-glt1011280800is1.dts \
            file://dts/freescale/imx93-cargt-00324-00326-glt1011280800is1.dtsi \
            file://dts/freescale/imx93-cargt-00324.dtsi \
            file://dts/freescale/imx91-cargt-00363-00365.dts \
            file://dts/freescale/imx91-cargt-00363-osm-som.dts \
            file://dts/freescale/imx93-cargt-00363-00365.dts \
            file://dts/freescale/imx93-cargt-00363-00365-glt0557201280is1.dts \
            file://dts/freescale/imx93-cargt-00363-00365-glt0557201280is1.dtsi \
            file://dts/freescale/imx93-cargt-00363-00365-glt1011280800is1.dts \
            file://dts/freescale/imx93-cargt-00363-00365-glt1011280800is1.dtsi \
            file://dts/freescale/imx93-cargt-00363-osm-som.dts \
            "

do_patch:append() {
    if [ -d "${UNPACKDIR}/dts/freescale" ]; then
        cp -a ${UNPACKDIR}/dts/freescale/. ${S}/arch/arm64/boot/dts/freescale/
    fi
}

SRC_URI += "file://0002-Add-support-for-Globaltech-GTG-panels.patch \
            file://0005-Move-ili9881c-panel-initialization-from-the-prepare-.patch \
            file://0006-Add-device-tree-files-for-00377.patch \
            file://0012-Improve-panel-initialization-error-handling-and-rese.patch \
            file://0013-Add-support-for-the-GLT028240320IS1-display-on-the-C.patch \
            file://0020-Add-FlexCAN-support-and-update-UART-RTS-CTS-configur.patch \
            file://0021-Add-device-tree-support-for-i.MX8MP-00377-OSM-L-SOM-.patch \
            file://0022-Reorganize-device-tree-source-file-for-the-Cargt-i.M.patch \
            file://0023-Add-device-tree-support-for-OS08A20-camera-and-enabl.patch \
            file://0024-Add-HDMI-support-for-Cargt-i.MX8MP-00377-OSM-L-SOM-o.patch \
            file://0031-serial-imx-fall-back-to-PIO-RX-if-DMA-prep-fails.patch \
            file://0032-dma-imx-sdma-restore-runtime-PM-wake-before-per-op-c.patch \
            file://0033-serial-imx-revert-TXTL_DEFAULT-to-2-test.patch \
            file://0034-drm-bridge-sec-dsim-config-esc-byte-clock-before-pa.patch \
            file://0035-clk-imx93-drop-CLK_SET_RATE_PARENT-from-media_disp_p.patch \
            file://0036-drm-imx-dw_mipi_dsi-imx-round-pixel-clock-through-th.patch \
            file://0039-arm64-dts-freescale-register-Cargt-board-dtb-y-entri.patch \
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

# 2026-09-02: 0035/0036/0037 (0037 has since been extracted to the standalone
# imx93-cargt-00363-00365-glt0557201280is1.dtsi file -- see the header comment
# there for its half of this fix) fix the long-standing DSI shearing bug on
# imx93-cargt-00363-00365 (5.5in GLT0557201280IS1-CTP panel) that had been
# paused since 2026-07-17. Two other real hypotheses were tested on hardware
# and disproven along the way (not committed): the new unconditional
# DRM_BUS_FLAG_PIXDATA_SAMPLE_NEGEDGE in dw-mipi-dsi.c's
# dw_mipi_dsi_bridge_atomic_check() (new vs. scarthgap, but opting out of it
# made no visible difference), and reversing the ili9881c panel driver's
# .prepare()/.enable() MIPI-init split (made things strictly worse -- DCS
# command FIFO write timeouts, display went fully black -- confirming
# .prepare() genuinely is the right place for MIPI comms on this platform,
# despite a stale/misleading code comment claiming otherwise).
# All three of 0035-0037 are required together, confirmed on real hardware:
#  - 0035 stops media_disp_pix's clk_set_rate() (called by lcdifv3_set_mode()
#    on every atomic_enable) from silently reprogramming video_pll itself.
#  - 0036 makes dw_mipi_dsi_mode_fixup() report the CRTC's adjusted mode
#    clock as what the LCDIF pixel clock can actually achieve, not the
#    DPHY's independent (and different) PLL-derived value -- without this,
#    the CRTC timing generator and the real pixel clock drift out of phase
#    across a line, which is what actually produced the shearing artifact.
#  - 0037 restores this board's &lcdif assigned-clocks (silently orphaned by
#    wrynose's DTSI restructuring -- assigned-clock-rates with no
#    assigned-clocks does nothing), pinning video_pll to a specific rate at
#    boot. Confirmed via a real hardware test that leaving video_pll at
#    whatever wrynose's stock DT settles on (rather than this specific,
#    scarthgap-matching rate) still shears even with 0035/0036 applied --
#    all three fixes are genuinely required, not just the first two.

# 2026-09-03: 0038 fixes HaLow (00375/MM6108) SDIO enumeration on
# imx93-cargt-00324-00326. Root-caused on real hardware: the base board
# file's usdhc3_pwrseq/reg_usdhc3_vmmc nodes are wired for the *other*
# (NXP/Cypress) M.2 module's WL_REG_ON/BT_REG_ON convention, but pca9555
# pin 13 is actually the MM6108's own RESET_N -- any pwrseq re-toggling
# RESET_N on every probe/retry cycle prevents SDIO enumeration entirely.
# Just overriding vmmc-supply away from reg_usdhc3_vmmc (the old approach)
# was not enough: both base nodes auto-probe on their compatible string
# regardless of whether this overlay references them, so regulator-usdhc3
# was still left claiming pin 13 (permanently deasserted/low, since nothing
# ever called regulator_enable() on an unreferenced node) -- holding
# RESET_N asserted the whole time. Fix deletes both nodes entirely (which
# also required /delete-property/ mmc-pwrseq -- the SOM-level dtsi's
# &usdhc3 override references usdhc3_pwrseq by phandle, so dtc fails to
# link unless that property is dropped too) and adds vqmmc-supply
# (required by the morse_sdio driver's mm6108_sdio@0 node) plus
# non-removable (safe again now that pwrseq-driven card detect is gone).
# Paired with the morse-firmware/driver version-alignment fix in
# meta-morsemicro (firmware bumped to the 1.16 release line to match
# morsemicro-driver's existing SRCREV 1.16.4 -- the two had drifted out of
# sync, causing a MORSE_CMD_SEMVER_MAJOR mismatch hard-fail). Both fixes
# together confirmed on real hardware: full wlan0 HaLow AP scan success.

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