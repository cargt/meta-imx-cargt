LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "grow-data-part.service"

RDEPENDS:${PN} += "bash"

SRC_URI:append = " file://grow-data-part.service \
                   file://grow-data-part.sh \
                   "
FILES:${PN} = "${systemd_unitdir}/system/grow-data-part.service \
               /usr/bin/grow-data-part.sh \
               "

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/grow-data-part.service ${D}/${systemd_unitdir}/system

  mkdir -p ${D}/usr/bin
  cp -f ${WORKDIR}/grow-data-part.sh ${D}/usr/bin/grow-data-part.sh
  chmod +x ${D}/usr/bin/grow-data-part.sh
} 


