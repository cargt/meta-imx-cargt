# Start mosquitto after network.target instead of waiting for
# network-online.target. Upstream's unit waits for it, so on NetworkManager
# images boot holds mosquitto (and cargt-python-nm-mqtt behind it) until
# NetworkManager-wait-online finishes, 20 to 30 s on boards with the IW612
# while NM runs its first Wi-Fi scans. The stock mosquitto.conf configures no
# listener, so mosquitto 2.x listens on localhost:1883 only, which is up long
# before network.target. A product that binds a listener to a specific
# interface address needs network-online.target back:
#   a mosquitto.service drop-in with Wants= and After=network-online.target.
do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        sed -i -e '/^Wants=network-online.target$/d' \
            -e 's/^After=network-online.target$/After=network.target/' \
            ${D}${systemd_unitdir}/system/mosquitto.service
        # sed exits 0 when nothing matches, so check the result: fail if
        # upstream changed the unit and the edit no longer applies.
        if ! grep -q '^After=network.target$' ${D}${systemd_unitdir}/system/mosquitto.service || \
           grep -q 'network-online' ${D}${systemd_unitdir}/system/mosquitto.service; then
            bbfatal "mosquitto.service changed upstream; update this bbappend"
        fi
    fi
}
