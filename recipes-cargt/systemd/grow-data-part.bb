SUMMARY = "Grow the data partition to the end of the boot disk"
DESCRIPTION = "At boot, extends the partition labelled data on the boot disk \
to the end of the disk and grows its ext4 filesystem online. Does nothing once \
the partition fills the disk."
LICENSE = "CLOSED"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "grow-data-part.service"

SRC_URI = " \
    file://grow-data-part.service \
    file://grow-data-part.sh \
"

RDEPENDS:${PN} += "util-linux-sfdisk util-linux-partx util-linux-lsblk e2fsprogs-resize2fs"

FILES:${PN} = " \
    ${systemd_system_unitdir}/grow-data-part.service \
    ${bindir}/grow-data-part.sh \
"

do_install() {
    install -d ${D}${systemd_system_unitdir} ${D}${bindir}
    install -m 0644 ${UNPACKDIR}/grow-data-part.service ${D}${systemd_system_unitdir}/
    install -m 0755 ${UNPACKDIR}/grow-data-part.sh ${D}${bindir}/
}
