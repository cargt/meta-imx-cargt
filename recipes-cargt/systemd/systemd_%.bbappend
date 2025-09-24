FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://10-bridge.netdev \
            file://20-bridge.network \
            file://50-eth0.network \
            file://50-br0-member-eth0.network \
            file://51-eth1.network \
            file://51-eth-lan.network \
            file://51-br0-member-eth1.network \
            file://52-wlan0.network \
            file://52-br0-member-wlan0.network \
            file://81-can1.network \
            file://80-can0.network \
        "

# PACKAGECONFIG[unmanaged-network] = ""

do_install:append () {

    install -d ${D}${sysconfdir}/systemd/network

    # Configure the Ethernet networks 
    # Only install the systemd networkd config for ethernet interfaces when connman is NOT included
    if ${@bb.utils.contains('DISTRO_FEATURES', 'connman', 'true', 'false', d)}; then
        install -Dm 0644 ${WORKDIR}/51-eth-lan.network ${D}${sysconfdir}/systemd/network/    
    else
        # Install bridge mode devices if we are an access point
        if ${@bb.utils.contains('DISTRO_FEATURES', 'cargt-ap', 'true', 'false', d)}; then
            install -Dm 0644 ${WORKDIR}/10-bridge.netdev ${D}${sysconfdir}/systemd/network/    
            install -Dm 0644 ${WORKDIR}/20-bridge.network ${D}${sysconfdir}/systemd/network/    
            install -Dm 0644 ${WORKDIR}/50-br0-member-eth0.network ${D}${sysconfdir}/systemd/network/    
            install -Dm 0644 ${WORKDIR}/51-br0-member-eth1.network ${D}${sysconfdir}/systemd/network/    
            install -Dm 0644 ${WORKDIR}/52-br0-member-wlan0.network ${D}${sysconfdir}/systemd/network/    
        else
            install -Dm 0644 ${WORKDIR}/50-eth0.network ${D}${sysconfdir}/systemd/network/    
            install -Dm 0644 ${WORKDIR}/51-eth1.network ${D}${sysconfdir}/systemd/network/    
            if ${@bb.utils.contains('MACHINE_FEATURES', 'morsemicro-ap', 'true', 'false', d)}; then
                install -Dm 0644 ${WORKDIR}/52-wlan0.network ${D}${sysconfdir}/systemd/network/    
            fi
        fi
    fi

    # Configure the can networks    
    install -Dm 0644 ${WORKDIR}/80-can0.network ${D}${sysconfdir}/systemd/network/    
    install -Dm 0644 ${WORKDIR}/81-can1.network ${D}${sysconfdir}/systemd/network/    

}

