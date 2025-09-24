LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "nftables.service"

SRC_URI:append = " file://nftables.service \
                   file://nftables.conf \
                  "
FILES:${PN} = "${systemd_unitdir}/system/nftables.service \ 
                ${sysconfdir}/nftables/nftables.conf \
               "
               
do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/nftables.service ${D}/${systemd_unitdir}/system
  install -d ${D}/${sysconfdir}/nftables
  install -m 0644 ${WORKDIR}/nftables.conf ${D}${sysconfdir}/nftables
}


