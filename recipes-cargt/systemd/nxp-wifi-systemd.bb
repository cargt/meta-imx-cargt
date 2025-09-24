LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "nxp-wifi.service"

SRC_URI:append = " file://nxp-wifi.service "
FILES:${PN} = "${systemd_unitdir}/system/nxp-wifi.service"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/nxp-wifi.service ${D}/${systemd_unitdir}/system
}


