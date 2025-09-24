LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "nxp-bluetooth.service"

SRC_URI:append = " file://nxp-bluetooth.service "
FILES:${PN} = "${systemd_unitdir}/system/nxp-bluetooth.service"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/nxp-bluetooth.service ${D}/${systemd_unitdir}/system
}


