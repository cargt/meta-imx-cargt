LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "kea-dhcp6.service"

SRC_URI:append = " file://kea-dhcp6.service \
                  "
FILES:${PN} = "${systemd_unitdir}/system/kea-dhcp6.service \ 
               "
               
do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/kea-dhcp6.service ${D}/${systemd_unitdir}/system
}


