SRCBRANCH = "lf-6.18.20_2.0.0"
SRCREV = "${AUTOREV}"

# Silence moal's driver-debug logging (verbose scan/state messages on the
# console) by default. drvdbg can't be set via wifi_mod_para.conf (see the
# comment in that file itself) -- it must go through the modprobe options
# line, so this overrides meta-imx-bsp's module_conf_moal wholesale rather
# than appending, since Kconfig-style "+=" isn't meaningful for this
# single-line string variable.
module_conf_moal = "options moal mod_para=nxp/wifi_mod_para.conf drvdbg=0x00000000"
