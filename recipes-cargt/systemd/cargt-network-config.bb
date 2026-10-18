SUMMARY = "Cargt systemd-networkd configuration"
DESCRIPTION = "Ethernet/bridge/WLAN/CAN .network and .netdev files for \
systemd-networkd, chosen by the distro's network manager and the machine's \
features, plus the networkd wait-online drop-in."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# The installed files depend on MACHINE_FEATURES (morsemicro-ap), so this is
# machine-specific. They used to be installed by systemd_%.bbappend, which made
# systemd (packaged for the shared tune arch) differ between machines: each
# machine overwrote the others' systemd in the feed and rebuilt everything
# signed against it.
PACKAGE_ARCH = "${MACHINE_ARCH}"

# Takes these files over from older systemd packages on devices being upgraded
RREPLACES:${PN} = "systemd"

S = "${UNPACKDIR}"

SRC_URI += "file://10-bridge.netdev \
            file://20-bridge.network \
            file://50-eth0.network \
            file://50-br0-member-eth0.network \
            file://51-eth1.network \
            file://50-eth0-dhcp.network \
            file://51-eth1-dhcp.network \
            file://51-br0-member-eth1.network \
            file://52-wlan0.network \
            file://52-br0-member-wlan0.network \
            file://81-can1.network \
            file://80-can0.network \
            file://50-cargt-networkmanager-wait-online.conf \
        "

do_install() {

    install -d ${D}${sysconfdir}/systemd/network

    # Configure the Ethernet networks
    # Install bridge mode devices if we are an access point
    if ${@bb.utils.contains('DISTRO_FEATURES', 'cargt-ap', 'true', 'false', d)}; then
        install -Dm 0644 ${UNPACKDIR}/10-bridge.netdev ${D}${sysconfdir}/systemd/network/
        install -Dm 0644 ${UNPACKDIR}/20-bridge.network ${D}${sysconfdir}/systemd/network/
        install -Dm 0644 ${UNPACKDIR}/50-br0-member-eth0.network ${D}${sysconfdir}/systemd/network/
        install -Dm 0644 ${UNPACKDIR}/51-br0-member-eth1.network ${D}${sysconfdir}/systemd/network/
        install -Dm 0644 ${UNPACKDIR}/52-br0-member-wlan0.network ${D}${sysconfdir}/systemd/network/
    elif ${@bb.utils.contains('DISTRO_FEATURES', 'networkmanager', 'true', 'false', d)}; then
        # NetworkManager owns eth0/eth1, so keep networkd's hands off them
        install -Dm 0644 ${UNPACKDIR}/50-eth0.network ${D}${sysconfdir}/systemd/network/
        install -Dm 0644 ${UNPACKDIR}/51-eth1.network ${D}${sysconfdir}/systemd/network/
        if ${@bb.utils.contains('MACHINE_FEATURES', 'morsemicro-ap', 'true', 'false', d)}; then
            install -Dm 0644 ${UNPACKDIR}/52-wlan0.network ${D}${sysconfdir}/systemd/network/
        fi
    else
        # No NetworkManager in this distro (e.g. fsl-imx-xwayland), so let
        # networkd run DHCP on eth0/eth1 rather than leaving them unmanaged
        install -Dm 0644 ${UNPACKDIR}/50-eth0-dhcp.network ${D}${sysconfdir}/systemd/network/
        install -Dm 0644 ${UNPACKDIR}/51-eth1-dhcp.network ${D}${sysconfdir}/systemd/network/
        if ${@bb.utils.contains('MACHINE_FEATURES', 'morsemicro-ap', 'true', 'false', d)}; then
            install -Dm 0644 ${UNPACKDIR}/52-wlan0.network ${D}${sysconfdir}/systemd/network/
        fi
    fi

    # Configure the can networks
    install -Dm 0644 ${UNPACKDIR}/80-can0.network ${D}${sysconfdir}/systemd/network/
    install -Dm 0644 ${UNPACKDIR}/81-can1.network ${D}${sysconfdir}/systemd/network/

    # Skip networkd's wait-online when NetworkManager is installed (see the drop-in)
    install -Dm 0644 ${UNPACKDIR}/50-cargt-networkmanager-wait-online.conf \
        ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/50-cargt-networkmanager-wait-online.conf

}


FILES:${PN} = "${sysconfdir}/systemd/network ${systemd_system_unitdir}/systemd-networkd-wait-online.service.d"
