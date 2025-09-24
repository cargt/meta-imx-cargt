LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "kea-ctrl-agent.service"

SRC_URI:append = " file://kea-ctrl-agent.service \
                  "
FILES:${PN} = "${systemd_unitdir}/system/kea-ctrl-agent.service \
               "
               
do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/kea-ctrl-agent.service ${D}/${systemd_unitdir}/system
}

