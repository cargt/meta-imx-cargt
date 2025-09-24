LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://cargt-swupdate-mods.cfg \
            "

FILESEXTRAPATHS:prepend := "${THISDIR}/swupdate:" 
SRC_URI += " file://swupdate.cfg \
            "

SW_VER_STRING ?= "undefined"

do_install:append() {
    mkdir -p ${D}/etc
    cp -f ${WORKDIR}/swupdate.cfg ${D}/etc/swupdate.cfg         
}

RDEPENDS:${PN} += "lua tar zstd"
DEPENDS += "kern-tools-native systemd"


