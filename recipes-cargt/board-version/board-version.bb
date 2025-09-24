LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/${MACHINE}:"

SRC_URI = " file://hw_ver.txt \
            "

INSANE_SKIP:${PN} += "already-stripped"

SW_VER_STRING ?= "undefined"

do_install:append() {
    mkdir -p ${D}/etc
    cp -f ${WORKDIR}/hw_ver.txt ${D}/etc/hwrevision
    echo ${SW_VER_STRING} > ${D}/etc/sw-versions    
}
