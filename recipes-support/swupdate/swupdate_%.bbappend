FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://cargt-swupdate-mods.cfg \
            file://cargt-logo-full-color.png \
            "

FILESEXTRAPATHS:prepend := "${THISDIR}/swupdate:" 
SRC_URI += " file://swupdate.cfg \
            "

SW_VER_STRING ?= "undefined"

do_install:append() {
    mkdir -p ${D}/etc
    cp -f ${UNPACKDIR}/swupdate.cfg ${D}/etc/swupdate.cfg

    # Replace the web UI background with the Cargt logo
    install -m 0644 ${UNPACKDIR}/cargt-logo-full-color.png ${D}${wwwdir}/images/background.png
    rm -f ${D}${wwwdir}/images/background.jpg
    sed -i -e 's|url(../images/background.jpg)|url(../images/background.png)|' \
           -e 's|background-size:cover|background-size:contain;background-color:#fff|' \
           ${D}${wwwdir}/css/swupdate.min.css
}

RDEPENDS:${PN} += "lua tar zstd"
DEPENDS += "kern-tools-native systemd"


