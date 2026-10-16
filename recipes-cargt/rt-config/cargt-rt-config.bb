SUMMARY = "System configuration for the cargt-imx-rt distro"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://cargt-rt-ethercat.conf"

S = "${UNPACKDIR}"

do_install() {
    install -D -m 0644 ${UNPACKDIR}/cargt-rt-ethercat.conf \
        ${D}${sysconfdir}/modprobe.d/cargt-rt-ethercat.conf
}
