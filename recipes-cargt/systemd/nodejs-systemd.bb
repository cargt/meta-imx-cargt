LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "nodejs.service"

SRC_URI:append = " file://nodejs.service \
                   file://main.js \
                   "

FILES:${PN} += "${systemd_unitdir}/system/nodejs.service \
                ${libdir}/node/main.js \
                "

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/nodejs.service ${D}/${systemd_unitdir}/system
  install -d ${D}/${libdir}/node
  install -m 0644 ${WORKDIR}/main.js ${D}/${libdir}/node
}

