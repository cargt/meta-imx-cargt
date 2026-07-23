
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:class-target = " \
	file://fw-env-geometry.conf \
	file://fw-env-config-gen.sh \
	file://fw-env-config.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN}:class-target = "fw-env-config.service"
SYSTEMD_AUTO_ENABLE:${PN}:class-target = "enable"

# fw_env.config is regenerated at every boot by fw-env-config.service,
# using the geometry below, once the actual boot device (eMMC vs SD
# card) is known - see fw-env-config-gen.sh. This is because U-Boot
# keeps its environment at the same offset/size on every boot medium,
# but the device node differs depending on which one was booted from;
# a static fw_env.config can only ever be correct for one of them.
do_install:append:class-target() {
	install -d ${D}${sysconfdir}
	install -d ${D}${bindir}
	install -d ${D}${systemd_system_unitdir}

	install -m 644 ${WORKDIR}/fw-env-geometry.conf ${D}${sysconfdir}
	install -m 755 ${WORKDIR}/fw-env-config-gen.sh ${D}${bindir}
	install -m 644 ${WORKDIR}/fw-env-config.service ${D}${systemd_system_unitdir}
}

FILES:${PN}:append:class-target = " \
	${sysconfdir}/fw-env-geometry.conf \
	${bindir}/fw-env-config-gen.sh \
	${systemd_system_unitdir}/fw-env-config.service \
"




# Fixup for the libubootenv which rely on uboot-config class for no good reason.
#
# This is not intended to be permanent but we need to get the integration
# working and there is no good solution for now so we are adding this in a
# non-intrusive way and using the `IMX_DEFAULT_BOOTLOADER` as a guard to do any
# code execution.

def fixup_uboot_config_dependency(d):
    ubootmachine = d.getVar("UBOOT_MACHINE")
    ubootconfig = (d.getVar('UBOOT_CONFIG') or "").split()
    imx_default_bootloader = d.get('IMX_DEFAULT_BOOTLOADER')

    if not ubootmachine and not ubootconfig and imx_default_bootloader:
       # FIXME: We need to provide the UBOOT_MACHINE or UBOOT_CONFIG to allow libubootenv to
       # build. This is caused by the commit below:
       #
       # ,----[ libubootenv change ]
       # | commit 10aa1291979fb90bed1beb49be4d406ed0e1e4d5 ┃
       # | ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━
       # | Author: Ming Liu <liu.ming50@gmail.com>
       # | Date:   Tue Aug 25 20:08:01 2020 +0200
       # |
       # |     libubootenv: inherit uboot-config
       # |
       # |     This mainly aims to involve in the sanity check of UBOOT_CONFIG and
       # |     UBOOT_MACHINE, it will throw a error message at recipe parsing time if
       # |     neither of them is set, and libubootenv would be skipped.
       # |
       # |     Signed-off-by: Ming Liu <liu.ming50@gmail.com>
       # |     Signed-off-by: Richard Purdie <richard.purdie@linuxfoundation.org>
       # `----
       ubootmachine = d.getVar("UBOOT_MACHINE:pn-%s" % imx_default_bootloader)
       ubootconfig = (d.getVar("UBOOT_CONFIG:pn-%s" % imx_default_bootloader) or "").split()

       d.setVar("UBOOT_CONFIG", ubootconfig)
       d.setVar("UBOOT_MACHINE", ubootmachine)

python fixup_uboot_config_dependency_handler() {
    fixup_uboot_config_dependency(d)
}

fixup_uboot_config_dependency_handler[eventmask] = "bb.event.RecipePreFinalise"
addhandler fixup_uboot_config_dependency_handler
