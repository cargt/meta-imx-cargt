SUMMARY = "PREEMPT_RT bring-up check: kernel, system health and cyclictest latency"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://cargt-rt-check"

S = "${UNPACKDIR}"

do_install() {
    install -D -m 0755 ${UNPACKDIR}/cargt-rt-check ${D}${bindir}/cargt-rt-check
}

RDEPENDS:${PN} = "bash coreutils util-linux-dmesg iproute2 rt-tests stress-ng"
