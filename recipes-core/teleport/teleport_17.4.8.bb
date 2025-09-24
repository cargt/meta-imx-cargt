DESCRIPTION = "Installs the Teleport Client, NOTE: this recipe does not compile the source code, it only installs the pre-compiled binaries from goteleport.com/download"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
SUMMARY = "Teleport Client"
FILE_NAME = "teleport-v${PV}-linux-arm64-bin.tar.gz"

SRC_URI = "https://cdn.teleport.dev/${FILE_NAME}"

SHASUM_URI = "https://cdn.teleport.dev/${FILE_NAME}.sha256"

S = "${WORKDIR}/teleport"

# Disable already-stripped as it is not needed
INSANE_SKIP:${PN} += "already-stripped"
INSANE_SKIP:${PN}-tbot += "ldflags"

# get the sha256sum from the remote file
do_fetch[prefuncs] += "fetch_checksums"
python fetch_checksums() {
    import urllib
    for line in urllib.request.urlopen(d.getVar("SHASUM_URI")):
        (sha, filename) = line.decode("ascii").strip().split()
        if filename == d.getVar("FILE_NAME"):
            d.setVarFlag("SRC_URI", "sha256sum", sha)
            return
    bb.error("Could not find remote checksum")
}

PACKAGES = "${PN} ${PN}-tctl ${PN}-tsh ${PN}-tbot"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/teleport/teleport ${D}${bindir}
    install -m 0755 ${WORKDIR}/teleport/tctl ${D}${bindir}
    install -m 0755 ${WORKDIR}/teleport/tsh ${D}${bindir}
    install -m 0755 ${WORKDIR}/teleport/tbot ${D}${bindir}

    install -d ${D}/var/lib/teleport
}

FILES:${PN} = "${bindir}/teleport \
/var/lib/teleport \
"
FILES:${PN}-tctl = "${bindir}/tctl"
FILES:${PN}-tsh = "${bindir}/tsh"
FILES:${PN}-tbot = "${bindir}/tbot"

INSANE_SKIP:${PN} += "ldflags"
