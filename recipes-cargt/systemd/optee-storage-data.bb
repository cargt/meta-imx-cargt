SUMMARY = "Keep OP-TEE secure storage on /data"
DESCRIPTION = "Points tee-supplicant's REE FS secure storage at /data/tee, \
which both A/B rootfs slots share, instead of /var/lib/tee on the rootfs, so \
OP-TEE keys and PKCS#11 objects survive an update. Creates /data/tee once \
grow-data-part has mounted /data."
LICENSE = "CLOSED"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "optee-storage-data.service"

S = "${UNPACKDIR}"

SRC_URI = " \
    file://optee-storage-data.conf \
    file://optee-storage-data.service \
"

RDEPENDS:${PN} += "optee-client grow-data-part coreutils"

FILES:${PN} = " \
    ${systemd_system_unitdir}/optee-storage-data.service \
    ${systemd_system_unitdir}/tee-supplicant@.service.d/optee-storage-data.conf \
"

do_install() {
    install -d ${D}${systemd_system_unitdir}/tee-supplicant@.service.d
    install -m 0644 ${UNPACKDIR}/optee-storage-data.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${UNPACKDIR}/optee-storage-data.conf ${D}${systemd_system_unitdir}/tee-supplicant@.service.d/
}
