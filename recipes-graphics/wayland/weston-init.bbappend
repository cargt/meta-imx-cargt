# Cargt desktop background: the logo on Kaitoke Green (dark, default) or
# Light Gray, as in the boot splash. Both images are installed, so a device
# can switch by editing background-image/background-color in weston.ini.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# "dark" or "light"
CARGT_WESTON_THEME ?= "dark"
CARGT_WESTON_COLOR[dark] = "0xff004437"
CARGT_WESTON_COLOR[light] = "0xfff7f9fa"

SRC_URI += " \
    file://cargt-background-dark.png \
    file://cargt-background-light.png \
"

do_install:append() {
    for t in dark light; do
        install -Dm 0644 ${UNPACKDIR}/cargt-background-$t.png ${D}${datadir}/weston/cargt-background-$t.png
    done
    sed -i -e '/^\[shell\]/a background-image=${datadir}/weston/cargt-background-${CARGT_WESTON_THEME}.png\nbackground-type=centered\nbackground-color=${@d.getVarFlag("CARGT_WESTON_COLOR", d.getVar("CARGT_WESTON_THEME"))}' \
        ${D}${sysconfdir}/xdg/weston/weston.ini
}

FILES:${PN} += "${datadir}/weston/cargt-background-*.png"
