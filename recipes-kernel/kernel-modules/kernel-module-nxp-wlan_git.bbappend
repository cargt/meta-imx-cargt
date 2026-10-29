SRCBRANCH = "lf-6.18.20_2.0.0"
SRCREV = "${AUTOREV}"

# Silence moal's driver-debug logging (verbose scan/state messages on the
# console) by default. drvdbg can't be set via wifi_mod_para.conf (see the
# comment in that file itself), so it goes on the modprobe options line; this
# overrides meta-imx-bsp's module_conf_moal wholesale, since "+=" isn't
# meaningful for this single-line string.
#
# The firmware is not chosen here: moal applies these module parameters first
# and then the chip's block in wifi_mod_para.conf replaces them, so the IW612
# (SDIW612 block) runs the combined Wi-Fi+BT firmware sduart_nw61x_v1.bin.se
# that the block names. Bluetooth depends on that: nxp-bluetooth.service only
# loads btnxpuart once mlan0 shows the combined firmware is running.
module_conf_moal = "options moal mod_para=nxp/wifi_mod_para.conf drvdbg=0x00000000"
