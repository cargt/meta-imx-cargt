LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "kea-dhcp-ddns.service"

SRC_URI:append = " file://kea-dhcp-ddns.service \
                  "
FILES:${PN} = "${systemd_unitdir}/system/kea-dhcp-ddns.service \ 
               "

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/kea-dhcp-ddns.service ${D}/${systemd_unitdir}/system
}


