# Build nmtui (NetworkManager's text UI, needs libnewt) so cargt-image-dev can
# ship it. The networkmanager package RRECOMMENDS every enabled sub-package, so
# drop nmtui from that list: other images keep nmcli only, and an image that
# wants nmtui asks for networkmanager-nmtui by name.
PACKAGECONFIG:append = " nmtui"
RRECOMMENDS:${PN}:remove = "${PN}-nmtui"

# Wi-Fi interfaces NetworkManager leaves alone. NM treats an idle interface as
# a disconnected Wi-Fi device and scans on it every 20 s to 2 min. On the
# 1x1 IW612 those scans (~7.5 s over 39 channels) share the radio with mlan0.
# A 10 ms UDP echo over mlan0 (2.4 GHz, -33 dBm, 12,001 packets) lost 565 and
# peaked at 945 ms with every interface managed, lost 119 and peaked at 440 ms
# with wfd0 unmanaged, and lost 1 and peaked at 193 ms with uap0 and wfd0
# unmanaged. wfd0 (Wi-Fi Direct) is unused, so it is unmanaged by default.
# uap0 stays managed so `nmcli connection add ... ifname uap0 mode ap` works;
# a product that never runs an access point should add it:
#   CARGT_NM_UNMANAGED_WIFI = "uap0 wfd0"
# Empty leaves every interface managed.
CARGT_NM_UNMANAGED_WIFI ?= "wfd0"

do_install:append() {
    if [ -n "${CARGT_NM_UNMANAGED_WIFI}" ]; then
        devs=""
        for i in ${CARGT_NM_UNMANAGED_WIFI}; do
            devs="${devs:+$devs;}interface-name:$i"
        done
        install -d ${D}${sysconfdir}/NetworkManager/conf.d
        printf '[keyfile]\nunmanaged-devices=%s\n' "$devs" \
            > ${D}${sysconfdir}/NetworkManager/conf.d/90-cargt-unmanaged-wifi.conf
        chmod 0644 ${D}${sysconfdir}/NetworkManager/conf.d/90-cargt-unmanaged-wifi.conf
    fi
}
