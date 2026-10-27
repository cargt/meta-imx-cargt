# Cargt boot splash: the Cargt logo over a flat progress bar, in a light
# (default) or dark theme. Progress comes from boot time rather than
# systemd's job count, and the splash turns with the panel's DT rotation.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# "light" or "dark"; written to /etc/default/psplash, which can be edited
# on the device.
CARGT_SPLASH_THEME ?= "light"

SRC_URI += " \
    file://0001-psplash-draw-a-flat-progress-bar-under-the-logo.patch \
    file://0002-psplash-systemd-estimate-progress-from-boot-time.patch \
    file://cargt-logo-light-200.png \
    file://cargt-logo-dark-480.png \
    file://cargt-logo-dark-200.png \
    file://cargt-psplash-start \
    file://zz-cargt.conf \
"

# /usr/bin/psplash stays a working fallback: the light theme, 480 px logo.
SPLASH_IMAGES = "file://cargt-logo-light-480.png;outsuffix=default"

# meta-imx drops the bar on Wayland builds; we want it.
PACKAGECONFIG_REMOVE = ""

# One binary per theme and logo size; cargt-psplash-start picks one at boot.
# The logos are flattened onto the theme background (psplash has no alpha).
CARGT_SPLASH_VARIANTS = "light-480 light-200 dark-480 dark-200"
# background, bar, bar track
CARGT_SPLASH_COLORS[light] = "0xf7,0xf9,0xfa 0x00,0xac,0x69 0xe1,0xe6,0xe9"
CARGT_SPLASH_COLORS[dark] = "0x00,0x44,0x37 0x26,0xff,0x91 0x1f,0x5a,0x4f"
# bar height, gap between logo and bar
CARGT_SPLASH_BAR[480] = "6 56"
CARGT_SPLASH_BAR[200] = "4 24"

python do_compile () {
    import shutil
    import subprocess

    workdir = d.getVar('UNPACKDIR')
    src = d.getVar('S')
    convertscript = "%s/make-image-header.sh" % src
    colors = "%s/psplash-colors.h" % src

    for variant in d.getVar('CARGT_SPLASH_VARIANTS').split():
        theme, size = variant.split('-')
        bg, bar, track = d.getVarFlag('CARGT_SPLASH_COLORS', theme).split()
        height, gap = d.getVarFlag('CARGT_SPLASH_BAR', size).split()

        # psplash.c includes this with quotes, so it must replace the one in ${S}
        with open(colors, 'w') as f:
            f.write("#ifndef _HAVE_PSPLASH_COLORS_H\n#define _HAVE_PSPLASH_COLORS_H\n")
            f.write("#define PSPLASH_BACKGROUND_COLOR %s\n" % bg)
            f.write("#define PSPLASH_TEXT_COLOR %s\n" % bar)
            f.write("#define PSPLASH_BAR_COLOR %s\n" % bar)
            f.write("#define PSPLASH_BAR_BACKGROUND_COLOR %s\n" % track)
            f.write("#define PSPLASH_BAR_HEIGHT %s\n" % height)
            f.write("#define PSPLASH_BAR_GAP %s\n" % gap)
            f.write("#endif\n")

        logo = "cargt-logo-%s.png" % variant
        if subprocess.call([convertscript, os.path.join(workdir, logo), 'POKY'], cwd=workdir):
            bb.fatal("Error calling convert script '%s'" % convertscript)
        shutil.copyfile(os.path.join(workdir, "cargt-logo-%s-img.h" % variant),
                        "%s/psplash-poky-img.h" % d.getVar('B'))
        # For some reason just updating the headers is not enough, we have to
        # touch the .c file in order to get it to rebuild
        os.utime("%s/psplash.c" % src, None)
        bb.build.exec_func("oe_runmake", d)
        shutil.copyfile("psplash", "psplash-%s" % variant)

    shutil.copyfile("psplash-light-480", "psplash-default")
}

do_install:append() {
    install -d ${D}${libexecdir}/psplash
    for v in ${CARGT_SPLASH_VARIANTS}; do
        install -m 0755 psplash-$v ${D}${libexecdir}/psplash/
    done
    install -m 0755 ${UNPACKDIR}/cargt-psplash-start ${D}${libexecdir}/psplash/

    install -d ${D}${sysconfdir}/default
    echo "CARGT_SPLASH_THEME=${CARGT_SPLASH_THEME}" > ${D}${sysconfdir}/default/psplash

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -Dm 0644 ${UNPACKDIR}/zz-cargt.conf \
            ${D}${systemd_system_unitdir}/psplash-start@.service.d/zz-cargt.conf

        # Start the splash with sysinit rather than when udev gets round to
        # fb0, which is seconds after the kernel made /dev/fb0. udev still
        # starts it if fb0 turns up later.
        sed -i -e '/^After=dev-%i.device/d' -e '/^Wants=dev-%i.device/d' \
            -e '/^\[Unit\]/a ConditionPathExists=/dev/%i' \
            ${D}${systemd_system_unitdir}/psplash-start@.service
        install -d ${D}${systemd_system_unitdir}/sysinit.target.wants
        ln -sf ../psplash-start@.service \
            ${D}${systemd_system_unitdir}/sysinit.target.wants/psplash-start@fb0.service
        ln -sf ../psplash-systemd.service \
            ${D}${systemd_system_unitdir}/sysinit.target.wants/psplash-systemd.service
    fi
}

FILES:${PN} += " \
    ${libexecdir}/psplash \
    ${sysconfdir}/default/psplash \
    ${systemd_system_unitdir}/psplash-start@.service.d \
    ${systemd_system_unitdir}/sysinit.target.wants \
"
CONFFILES:${PN} += "${sysconfdir}/default/psplash"
