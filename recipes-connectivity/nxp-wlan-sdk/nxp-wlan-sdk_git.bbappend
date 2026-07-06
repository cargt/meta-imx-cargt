require nxp-wlan-sdk_frdm.inc

# Updated for wrynose - verify branch matches meta-imx defaults
SRCBRANCH = "lf-6.18.23_2.0.0"
SRCREV = "${AUTOREV}"

do_install () {
    install -d ${D}${datadir}/nxp_wireless

    install -m 0644 README ${D}${datadir}/nxp_wireless
}
