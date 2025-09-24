LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "morsemicro-ap.service"

SRC_URI:append = " file://morsemicro-ap.service "
FILES:${PN} = "${systemd_unitdir}/system/morsemicro-ap.service"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/morsemicro-ap.service ${D}/${systemd_unitdir}/system
}


