SUMMARY = "Grow the data partition of the boot disk and mount it on /data"
DESCRIPTION = "At boot, extends the partition labelled data on the boot disk \
(the disk holding root=) to the end of the disk, grows its ext4 filesystem \
online and mounts it on /data. The grow does nothing once the partition fills \
the disk. /data is not in fstab because LABEL=data also matches a second disk, \
such as an SD card with a Cargt image in an eMMC-booted board."
LICENSE = "CLOSED"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "grow-data-part.service"

S = "${UNPACKDIR}"

SRC_URI = " \
    file://grow-data-part.service \
    file://grow-data-part.sh \
"

RDEPENDS:${PN} += "util-linux-sfdisk util-linux-partx util-linux-lsblk util-linux-findmnt \
                   util-linux-mountpoint e2fsprogs-resize2fs"

FILES:${PN} = " \
    ${systemd_system_unitdir}/grow-data-part.service \
    ${bindir}/grow-data-part.sh \
"

do_install() {
    install -d ${D}${systemd_system_unitdir} ${D}${bindir}
    install -m 0644 ${UNPACKDIR}/grow-data-part.service ${D}${systemd_system_unitdir}/
    install -m 0755 ${UNPACKDIR}/grow-data-part.sh ${D}${bindir}/
}
