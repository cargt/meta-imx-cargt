# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

# Unable to find any files that looked like license statements. Check the accompanying
# documentation and source headers and set LICENSE and LIC_FILES_CHKSUM accordingly.
#
# NOTE: LICENSE is being set to "CLOSED" to allow you to at least start building - if
# this is not accurate with respect to the licensing of the software being built (it
# will not be in most cases) you must specify the correct value before using this
# recipe for anything other than initial testing/development!
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

SRC_URI = "git://git@gitlab.com/cargt-internal/utils/cargt-python-nm-mqtt.git;protocol=ssh;branch=main"

SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "cargt-python-nm-mqtt.service "

# Runtime dependencies
RDEPENDS:${PN} += "mosquitto python3-sdbus-networkmanager python3-paho-mqtt "

do_install () {
    install -d ${D}/usr/bin
    install -Dm 0775 ${S}/nm_info.py ${D}/usr/bin
    install -Dm 0775 ${S}/nm_info_mqtt.py ${D}/usr/bin
  	install -d ${D}/${systemd_unitdir}/system
  	install -m 0644 ${S}/cargt-python-nm-mqtt.service ${D}/${systemd_unitdir}/system
}

FILES:${PN} = "${systemd_unitdir}/system/cargt-python-nm-mqtt.service \
				/usr/bin \
  				/usr/bin/nm_info_mqtt.py \
  				/usr/bin/nm_info.py \
				"


