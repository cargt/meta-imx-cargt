LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "poe-mqtt-publish.service \
                          poe-mqtt-publish.timer \
"

SRC_URI:append = " file://poe-mqtt-publish.service \
                    file://poe-mqtt-publish.timer \
"
FILES:${PN} = "${systemd_unitdir}/system/poe-mqtt-publish.service \
                  ${systemd_unitdir}/system/poe-mqtt-publish.timer \
"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/poe-mqtt-publish.service ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/poe-mqtt-publish.timer ${D}/${systemd_unitdir}/system
}


