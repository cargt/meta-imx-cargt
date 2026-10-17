SUMMARY = "System configuration for the cargt-imx-rt distro"
DESCRIPTION = "Stops EtherCAT drivers autoloading and keeps CPUs out of deep \
idle states, both for deterministic real-time behaviour."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://cargt-rt-ethercat.conf \
    file://cargt-rt-cpuidle.conf \
"

S = "${UNPACKDIR}"

do_install() {
    install -D -m 0644 ${UNPACKDIR}/cargt-rt-ethercat.conf \
        ${D}${sysconfdir}/modprobe.d/cargt-rt-ethercat.conf
    install -D -m 0644 ${UNPACKDIR}/cargt-rt-cpuidle.conf \
        ${D}${nonarch_libdir}/tmpfiles.d/cargt-rt-cpuidle.conf
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d"
