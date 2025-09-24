LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "mount-usb@.service"

SRC_URI:append = " file://mount-usb@.service \
                  file://mount-usb.rules"
FILES:${PN} = "${systemd_unitdir}/system/mount-usb@.service ${sysconfdir}/udev/rules.d/*"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/mount-usb@.service ${D}/${systemd_unitdir}/system

  install -d ${D}${sysconfdir}/udev/rules.d
  install -m 0644 ${WORKDIR}/mount-usb.rules ${D}${sysconfdir}/udev/rules.d/
}


