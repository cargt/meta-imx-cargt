do_install:append() {
    if ${@bb.utils.contains('MACHINE_FEATURES', 'cargt-router', 'true', 'false', d)}; then
        echo "# allow NTP requests from the local network" >> ${D}${sysconfdir}/ntp.conf
        echo "restrict 192.0.0.0 mask 255.255.255.0 nomodify notrap nopeer" >> ${D}${sysconfdir}/ntp.conf
    fi
}
