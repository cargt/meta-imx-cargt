LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "kea-dhcp4.service"

SRC_URI:append = " file://kea-dhcp4.service \
                  "
FILES:${PN} = "${systemd_unitdir}/system/kea-dhcp4.service \ 
               "

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/kea-dhcp4.service ${D}/${systemd_unitdir}/system
}


