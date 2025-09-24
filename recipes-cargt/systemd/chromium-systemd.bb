LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "chrome.service"

SRC_URI:append = " file://chrome.service "
FILES:${PN} += "${systemd_unitdir}/system/chrome.service"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/chrome.service ${D}/${systemd_unitdir}/system
}


 
