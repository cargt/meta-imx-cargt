SRCBRANCH = "lf-6.18.20_2.0.0"
SRCREV = "${AUTOREV}"

# - Silence moal's driver-debug logging (verbose scan/state messages on the
#   console) by default. drvdbg can't be set via wifi_mod_para.conf (see the
#   comment in that file itself) -- it must go through the modprobe options
#   line, so this overrides meta-imx-bsp's module_conf_moal wholesale rather
#   than appending, since Kconfig-style "+=" isn't meaningful for this
#   single-line string variable.
# - Force the plain WLAN-only firmware instead of the driver's
#   auto-detected combo (WiFi+BT single blob) firmware. Our IW612 modules
#   report combo-capable (magic == CHIP_MAGIC_VALUE) with no UART strap, so
#   the driver defaults to requesting SDSD9177_DEFAULT_COMBO_V1_FW_NAME
#   ("sdsd_nw61x_v1.bin.se"), which imx-firmware's current pinned commit
#   doesn't ship -- probe fails outright with no WiFi at all. Bluetooth on
#   these boards is already handled separately over its own lpuart/btnxpuart
#   link (see the 00363-00365/00324-00326 bluetooth DT fixes elsewhere in
#   this tree), so this board design never needed combo mode in the first
#   place. fw_name overrides the driver's auto-detected choice with the
#   plain WLAN firmware (SD9177_DEFAULT_WLAN_V1_FW_NAME), which imx-firmware
#   does ship and which the driver already resolves correctly on its own
#   (fw_name_wlan) -- this override just makes the primary fw_name field
#   agree with it instead of also trying, and failing, combo mode first.
module_conf_moal = "options moal mod_para=nxp/wifi_mod_para.conf drvdbg=0x00000000 fw_name=nxp/sd_w61x_v1.bin.se"
