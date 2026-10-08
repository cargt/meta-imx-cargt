LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

SRC_URI = "git://github.com/cargt/cargt-util-python-nm-mqtt.git;protocol=https;branch=main"

PV = "1.0+git${SRCPV}"
SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git"

inherit systemd imx-cargt-component-version

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "cargt-python-nm-mqtt.service"

# Runtime dependencies (see requirements.txt upstream)
RDEPENDS:${PN} += "mosquitto python3-sdbus python3-sdbus-networkmanager python3-paho-mqtt"

do_install () {
    install -d ${D}/usr/bin
    install -Dm 0775 ${S}/nm_info.py ${D}/usr/bin
    install -Dm 0775 ${S}/nm_info_mqtt.py ${D}/usr/bin

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${S}/cargt-python-nm-mqtt.service ${D}${systemd_unitdir}/system
}

FILES:${PN} = "${systemd_unitdir}/system/cargt-python-nm-mqtt.service \
                /usr/bin \
                /usr/bin/nm_info.py \
                /usr/bin/nm_info_mqtt.py \
                "
