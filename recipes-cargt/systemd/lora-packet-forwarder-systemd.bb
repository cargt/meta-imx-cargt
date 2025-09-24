LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "lora-packet-forwarder.service"

SRC_URI:append = " file://lora-packet-forwarder.service \
                  "
FILES:${PN} = "${systemd_unitdir}/system/lora-packet-forwarder.service \ 
               "
               
do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/lora-packet-forwarder.service ${D}/${systemd_unitdir}/system
}


