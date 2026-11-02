# Cargt desktop background: the logo on Kaitoke Green (dark, default) or
# Light Gray, as in the boot splash. Both themes are installed, so a device
# can switch by editing background-image/background-color in weston.ini.
# cargt-background-<theme>.png is the boot splash's 480 px logo, shared with
# psplash. cargt-background-<theme>-small.png is its 200 px logo padded to
# 200x48 with the theme color, for small panels such as the 320x240 00379
# SPI display (cargt-weston-spi-panel switches to it at runtime). An even
# height keeps "centered" on whole pixels; at 47 px the logo sat half a
# pixel off and its top and bottom rows blended into dark lines.
FILESEXTRAPATHS:prepend := "${THISDIR}/../../recipes-core/psplash/files:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# "dark" or "light". Dark by default, after the light boot splash
# (CARGT_SPLASH_THEME in psplash_git.bbappend).
CARGT_WESTON_THEME ?= "dark"
CARGT_WESTON_COLOR[dark] = "0xff004437"
CARGT_WESTON_COLOR[light] = "0xfff7f9fa"

# With the rdp MACHINE_FEATURE, let meta-freescale's weston-init append wire up
# screen sharing: it adds modules=screen-share.so to [core] and the TLS key
# pair to the [screen-share] command. Without it, weston.ini has no
# screen-share module, although Weston itself always has the RDP backend
# (weston_%.bbappend).
PACKAGECONFIG:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'rdp', 'rdp', '', d)}"

# Start sharing the display over RDP when Weston starts ("1"), instead of on
# Ctrl+Alt+S. Off by default: Weston's RDP backend has no login, so anyone who
# can reach port 3389 sees and controls the screen.
CARGT_WESTON_RDP_AUTOSTART ?= "0"

SRC_URI += "${@bb.utils.contains('MACHINE_FEATURES', 'rdp', 'file://cargt-rdp-keys.service', '', d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'rdp', 'cargt-rdp-keys.service', '', d)}"
RDEPENDS:${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'rdp', 'freerdp', '', d)}"

SRC_URI += " \
    file://cargt-logo-dark-480.png \
    file://cargt-logo-light-480.png \
    file://cargt-background-dark-small.png \
    file://cargt-background-light-small.png \
    file://cargt-weston-spi-panel \
    file://cargt-spi-panel.conf \
"

do_install:append() {
    for t in dark light; do
        install -Dm 0644 ${UNPACKDIR}/cargt-logo-$t-480.png ${D}${datadir}/weston/cargt-background-$t.png
        install -Dm 0644 ${UNPACKDIR}/cargt-background-$t-small.png ${D}${datadir}/weston/cargt-background-$t-small.png
    done
    sed -i -e '/^\[shell\]/a background-image=${datadir}/weston/cargt-background-${CARGT_WESTON_THEME}.png\nbackground-type=centered\nbackground-color=${@d.getVarFlag("CARGT_WESTON_COLOR", d.getVar("CARGT_WESTON_THEME"))}' \
        ${D}${sysconfdir}/xdg/weston/weston.ini

    # RDP screen sharing (rdp MACHINE_FEATURE). meta-freescale's append
    # points the TLS key pair at /etc/freerdp/keys; cargt-rdp-keys.service
    # generates it in /data/freerdp/keys instead, so move the paths there.
    if ${@bb.utils.contains('MACHINE_FEATURES', 'rdp', 'true', 'false', d)}; then
        install -Dm 0644 ${UNPACKDIR}/cargt-rdp-keys.service \
            ${D}${systemd_system_unitdir}/cargt-rdp-keys.service
        sed -i 's|=${sysconfdir}/freerdp/keys/|=/data/freerdp/keys/|g' \
            ${D}${sysconfdir}/xdg/weston/weston.ini
        grep -q -- '--rdp-tls-key=/data/freerdp/keys/server.key' ${D}${sysconfdir}/xdg/weston/weston.ini || \
            bbfatal "weston.ini: no --rdp-tls-key in [screen-share] to point at /data/freerdp/keys"
        if [ "${CARGT_WESTON_RDP_AUTOSTART}" = "1" ]; then
            sed -i 's/^#start-on-startup=true/start-on-startup=true/' \
                ${D}${sysconfdir}/xdg/weston/weston.ini
            grep -q '^start-on-startup=true' ${D}${sysconfdir}/xdg/weston/weston.ini || \
                bbfatal "weston.ini: no #start-on-startup=true in [screen-share] to enable"
        fi
    fi

    # meta-freescale's and meta-imx-bsp's weston-init appends both add
    # --log=${XDG_RUNTIME_DIR}/weston.log to weston.service's ExecStart, so
    # it ends up there twice. This layer's append runs after both (higher
    # layer priority); keep one.
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        sed -i 's|\(--log=\${XDG_RUNTIME_DIR}/weston.log \)\1\+|\1|' \
            ${D}${systemd_system_unitdir}/weston.service
    fi

    # The 00379 SPI display needs a pixman/RGB565 weston.ini at runtime.
    install -Dm 0755 ${UNPACKDIR}/cargt-weston-spi-panel ${D}${libexecdir}/cargt-weston-spi-panel
    install -Dm 0644 ${UNPACKDIR}/cargt-spi-panel.conf ${D}${systemd_system_unitdir}/weston.service.d/cargt-spi-panel.conf
}

FILES:${PN} += " \
    ${datadir}/weston/cargt-background-*.png \
    ${libexecdir}/cargt-weston-spi-panel \
    ${systemd_system_unitdir}/weston.service.d/cargt-spi-panel.conf \
"
