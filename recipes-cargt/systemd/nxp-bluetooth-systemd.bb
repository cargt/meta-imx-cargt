LICENSE = "CLOSED"
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "nxp-bluetooth.service"

SRC_URI:append = " file://nxp-bluetooth.service file://nxp-bluetooth.conf "
# bluetoothctl and bluetoothd power the controller on
RDEPENDS:${PN} = "bluez5"

FILES:${PN} = "${systemd_unitdir}/system/nxp-bluetooth.service ${sysconfdir}/modprobe.d/nxp-bluetooth.conf"

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${UNPACKDIR}/nxp-bluetooth.service ${D}/${systemd_unitdir}/system
  install -d ${D}${sysconfdir}/modprobe.d
  install -m 0644 ${UNPACKDIR}/nxp-bluetooth.conf ${D}${sysconfdir}/modprobe.d
}
