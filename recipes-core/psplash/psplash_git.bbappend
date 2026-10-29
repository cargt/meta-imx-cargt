# Cargt boot splash: the Cargt logo over a flat progress bar, in a light
# (default) or dark theme. Progress comes from boot time rather than
# systemd's job count, and the splash turns with the panel's DT rotation.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# "light" or "dark"; written to /etc/default/psplash, which can be edited
# on the device. Light by default, going into the dark Weston desktop
# (CARGT_WESTON_THEME in weston-init.bbappend).
CARGT_SPLASH_THEME ?= "light"

# Where psplash-systemd keeps how long boot takes. /var/lib isn't kept on
# a read-only rootfs (cargt images on squashfs machines), so use the data
# partition there; psplash-systemd finds the record once it's mounted.
CARGT_SPLASH_BOOT_TIME_DIR ?= "${@bb.utils.contains('MACHINE_FEATURES', 'squashfs', '/data/psplash', '${localstatedir}/lib/psplash', d)}"

# The theme can differ per machine and lands in /etc/default/psplash, so
# the package is per machine, not per SoC as meta-imx has it.
PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGE_ARCH:imx-generic-bsp = "${MACHINE_ARCH}"

SRC_URI += " \
    file://0001-psplash-draw-a-flat-progress-bar-under-the-logo.patch \
    file://0002-psplash-systemd-estimate-progress-from-boot-time.patch \
    file://cargt-logo-light-200.png \
    file://cargt-logo-dark-480.png \
    file://cargt-logo-dark-200.png \
    file://cargt-psplash-start \
    file://zz-cargt.conf \
    file://cargt-fbcon-detach.service \
    file://cargt-fbcon-attach.service \
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

    for variant in d.getVar('CARGT_SPLASH_VARIANTS').split():
        theme, size = variant.split('-')
        bg, bar, track = d.getVarFlag('CARGT_SPLASH_COLORS', theme).split()
        height, gap = d.getVarFlag('CARGT_SPLASH_BAR', size).split()

        # 0001 lets -D override psplash-colors.h, so ${S} stays untouched
        defs = "-DPSPLASH_BACKGROUND_COLOR=%s -DPSPLASH_TEXT_COLOR=%s " \
               "-DPSPLASH_BAR_COLOR=%s -DPSPLASH_BAR_BACKGROUND_COLOR=%s " \
               "-DPSPLASH_BAR_HEIGHT=%s -DPSPLASH_BAR_GAP=%s" % (bg, bar, bar, track, height, gap)
        localdata = bb.data.createCopy(d)
        localdata.setVar('EXTRA_OEMAKE', "%s 'CPPFLAGS=%s %s'" %
                         (d.getVar('EXTRA_OEMAKE') or '', d.getVar('CPPFLAGS') or '', defs))

        logo = "cargt-logo-%s.png" % variant
        if subprocess.call([convertscript, os.path.join(workdir, logo), 'POKY'], cwd=workdir):
            bb.fatal("Error calling convert script '%s'" % convertscript)
        shutil.copyfile(os.path.join(workdir, "cargt-logo-%s-img.h" % variant),
                        "%s/psplash-poky-img.h" % d.getVar('B'))
        # For some reason just updating the headers is not enough, we have to
        # touch the .c file in order to get it to rebuild
        os.utime("%s/psplash.c" % src, None)
        bb.build.exec_func("oe_runmake", localdata)
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
        install -d ${D}${systemd_system_unitdir}/psplash-systemd.service.d
        printf '[Service]\nEnvironment=PSPLASH_BOOT_TIME_DIR=%s\n' ${CARGT_SPLASH_BOOT_TIME_DIR} \
            > ${D}${systemd_system_unitdir}/psplash-systemd.service.d/zz-cargt.conf

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

        # Keep fbcon off the display under the splash and through Weston's
        # VT switch, then attach it again for the text consoles.
        install -m 0644 ${UNPACKDIR}/cargt-fbcon-detach.service \
            ${UNPACKDIR}/cargt-fbcon-attach.service ${D}${systemd_system_unitdir}/
        ln -sf ../cargt-fbcon-detach.service \
            ${D}${systemd_system_unitdir}/sysinit.target.wants/cargt-fbcon-detach.service
        install -d ${D}${systemd_system_unitdir}/graphical.target.wants
        ln -sf ../cargt-fbcon-attach.service \
            ${D}${systemd_system_unitdir}/graphical.target.wants/cargt-fbcon-attach.service
    fi
}

FILES:${PN} += " \
    ${libexecdir}/psplash \
    ${sysconfdir}/default/psplash \
    ${systemd_system_unitdir}/psplash-start@.service.d \
    ${systemd_system_unitdir}/psplash-systemd.service.d \
    ${systemd_system_unitdir}/sysinit.target.wants \
    ${systemd_system_unitdir}/graphical.target.wants \
    ${systemd_system_unitdir}/cargt-fbcon-*.service \
"
CONFFILES:${PN} += "${sysconfdir}/default/psplash"
