LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "poe-power.service"

SRC_URI:append = " file://poe-power.service "
FILES:${PN} = "${systemd_unitdir}/system/poe-power.service"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/poe-power.service ${D}/${systemd_unitdir}/system
}


