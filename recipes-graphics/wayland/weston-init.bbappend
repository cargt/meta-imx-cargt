# Cargt desktop background: the logo on Kaitoke Green (dark, default) or
# Light Gray, as in the boot splash. Both images are installed, so a device
# can switch by editing background-image/background-color in weston.ini.
# The images are the boot splash's 480 px logos, shared with psplash.
FILESEXTRAPATHS:prepend := "${THISDIR}/../../recipes-core/psplash/files:"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# "dark" or "light". Dark by default, after the light boot splash
# (CARGT_SPLASH_THEME in psplash_git.bbappend).
CARGT_WESTON_THEME ?= "dark"
CARGT_WESTON_COLOR[dark] = "0xff004437"
CARGT_WESTON_COLOR[light] = "0xfff7f9fa"

SRC_URI += " \
    file://cargt-logo-dark-480.png \
    file://cargt-logo-light-480.png \
    file://cargt-weston-spi-panel \
    file://cargt-spi-panel.conf \
"

do_install:append() {
    for t in dark light; do
        install -Dm 0644 ${UNPACKDIR}/cargt-logo-$t-480.png ${D}${datadir}/weston/cargt-background-$t.png
    done
    sed -i -e '/^\[shell\]/a background-image=${datadir}/weston/cargt-background-${CARGT_WESTON_THEME}.png\nbackground-type=centered\nbackground-color=${@d.getVarFlag("CARGT_WESTON_COLOR", d.getVar("CARGT_WESTON_THEME"))}' \
        ${D}${sysconfdir}/xdg/weston/weston.ini

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
