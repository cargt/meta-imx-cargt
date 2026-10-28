LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "nxp-wifi.service"

SRC_URI:append = " file://nxp-wifi.service "
FILES:${PN} = "${systemd_unitdir}/system/nxp-wifi.service"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${UNPACKDIR}/nxp-wifi.service ${D}/${systemd_unitdir}/system
}



# iw loads the regulatory database and checks the country (see nxp-wifi.service).
RDEPENDS:${PN} += "iw"
