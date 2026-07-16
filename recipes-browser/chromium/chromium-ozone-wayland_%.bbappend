FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://chromium.png \
        "

do_install:append () {

    install -d ${D}/usr/share/weston/icon/
    install -Dm 0644 ${UNPACKDIR}/chromium.png ${D}/usr/share/weston/icon/    
}

FILES:${PN} += "/usr/share/weston/icon/chromium.png \
                "