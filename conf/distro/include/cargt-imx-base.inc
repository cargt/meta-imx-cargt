require conf/distro/poky.conf

DISTRO = "imx-cargt"
DISTRO_NAME = "Cargt i.MX Release Distro"
DISTRO_VERSION = "6.18-wrynose"
DISTROOVERRIDES = "fsl"

MAINTAINER = "Cargt <tim.carney@cargt.com>"

POKY_DEFAULT_DISTRO_FEATURES:remove = "${POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE}"
POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE             ?= "wayland"
POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE:mx6-nxp-bsp ?= "wayland vulkan"
POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE:mx7-nxp-bsp ?= "wayland vulkan"
DISTRO_FEATURES:remove = "pulseaudio"
DISTRO_FEATURES:append = " opencl"

POKY_DEFAULT_DISTRO_FEATURES:append = " ${POKY_DEFAULT_DISTRO_FEATURES_IMX_APPEND}"
POKY_DEFAULT_DISTRO_FEATURES_IMX_APPEND             ?= "jailhouse xen"
POKY_DEFAULT_DISTRO_FEATURES_IMX_APPEND:mx6-nxp-bsp ?= ""
POKY_DEFAULT_DISTRO_FEATURES_IMX_APPEND:mx7-nxp-bsp ?= ""

DISTRO_FEATURES:append:mx8-nxp-bsp = " virtualization"
SKIP_META_VIRT_SANITY_CHECK = "1"

SKIP_META_SECURITY_SANITY_CHECK = "1"
SKIP_META_TPM_SANITY_CHECK = "1"

# Set a more generic tuning for code reuse across parts
DEFAULTTUNE:mx8-nxp-bsp    ?= "armv8a-crc-crypto"
# i.MX8M builds with "virtualization" in DISTRO_FEATURES (added for mx8 above,
# as in meta-imx), which changes recipes such as systemd (meta-virtualization
# turns on its openssl PACKAGECONFIG). It must not share the armv8a package
# arch with i.MX93, or the machines overwrite each other's packages in the
# shared feed. cortexa53-crypto matches meta-freescale's mx8m default. Hard
# assignment so a ?= default set earlier for this override can't win.
DEFAULTTUNE:mx8m-nxp-bsp = "cortexa53-crypto"
DEFAULTTUNE:mx8qm-nxp-bsp  ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8x-nxp-bsp   ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8ulp-nxp-bsp ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx9-nxp-bsp    ?= "armv8a-crc-crypto"
# i.MX91 builds with different DISTRO_FEATURES than i.MX93 (no wayland, opengl,
# vulkan or x11, see below), so it must not share the armv8a package arch with
# i.MX93: the two machines would overwrite/delete each other's packages in the
# shared feed.
# cortexa55 matches meta-freescale's mx91 default. Hard assignment so a ?=
# default set earlier for this override can't win.
DEFAULTTUNE:mx91-nxp-bsp = "cortexa55"
DEFAULTTUNE:mx93-nxp-bsp   ?= "armv8a-crc-crypto"
# i.MX95 has a GPU (Mali) and other machine features than i.MX93/8MP, so it must not share the
# armv8a package arch with them: the machines would overwrite/delete each other's packages in the
# shared armv8a deploy dir/feed. armv8-2a-crypto packages as "armv8-2a", used by no other Cargt SoC
# (imx93: armv8a, imx8mp: cortexa53-crypto, imx91: cortexa55). It needs the mx95-nxp-bsp override:
# imx-base.inc sets DEFAULTTUNE:mx95-generic-bsp ?= "cortexa55", which comes after mx9-nxp-bsp in
# OVERRIDES and would beat the mx9 line above, while mx95-nxp-bsp comes after mx95-generic-bsp.
DEFAULTTUNE:mx95-nxp-bsp = "armv8-2a-crypto"

PACKAGECONFIG:append:pn-gstreamer1.0-plugins-ugly = " x264"

PACKAGECONFIG:append:pn-perf = " jevents"

PACKAGECONFIG:append:pn-pulseaudio = " autospawn-for-root"

PACKAGECONFIG:append:mx93-nxp-bsp:pn-qtbase = " gles2"
PACKAGECONFIG:remove:mx93-nxp-bsp:pn-qtbase = "no-opengl linuxfb"

# meta-swupdate's recipes-graphics/lvgl/lvgl_%.bbappend unconditionally does
# `PACKAGECONFIG += "fbdev gridnav"`. That's meant for the upstream meta-oe
# lvgl_9.4.0 recipe (which defines those PACKAGECONFIG flags), but the
# wildcard also matches our own, unrelated lvgl_9.2.1.bb here, which defines
# neither -- failing do_configure's invalid-packageconfig QA check.
PACKAGECONFIG:remove:pn-lvgl = "fbdev gridnav"

# i.MX 91 has no GPU and no standard display interface, so every i.MX 91 board
# is treated as headless: wayland, opengl, vulkan and x11 are all stripped,
# which keeps Weston and Mesa out of the images. A small SPI panel such as the
# 00379 MikroBus display gets a lightweight GUI drawn straight to fbdev/DRM
# (e.g. qtbase linuxfb below), not Weston on Mesa's llvmpipe.
# Every i.MX 91 machine must get the same DISTRO_FEATURES: they all share the
# cortexa55 package arch, and machines with different DISTRO_FEATURES would
# overwrite each other's packages in the shared feed.
DISTRO_FEATURES:remove:mx91-nxp-bsp = "wayland opengl vulkan x11"
PACKAGECONFIG:remove:mx91-nxp-bsp:pn-qtbase = "gles2"
PACKAGECONFIG:append:mx91-nxp-bsp:pn-qtbase = " no-opengl linuxfb"

PACKAGECONFIG:append:pn-networkmanager = " modemmanager ppp"
# Recipes packaged for a shared (tune/SoC) arch must build identically for every
# machine sharing it, or the machines overwrite each other's packages in the feed.
# These only recommend a machine-specific package, which doesn't change their
# contents, so keep that dependency out of their signatures (as meta-freescale
# does for imx-gpu-viv->kernel-module-imx-gpu-viv).
SIGGEN_EXCLUDE_SAFE_RECIPE_DEPS:append = " \
    openssl->cryptodev-module \
    alsa-utils->alsa-state \
    systemd->cargt-network-config \
"
# smw is built against the machine's OP-TEE TA dev kit, so it is machine-specific,
# and so are the EdgeLock 2GO apps linked against it.
PACKAGE_ARCH:pn-smw = "${MACHINE_ARCH}"
PACKAGE_ARCH:pn-el2go-agent = "${MACHINE_ARCH}"
PACKAGE_ARCH:pn-oem-prov-app = "${MACHINE_ARCH}"

# Package feed (the apt sources.list in the image), for every machine: Cargt machine .conf files only append
# extra archs, and NXP's FRDM boards from meta-imx (whose images had no sources.list at all) get one too. The feed
# archs follow the machine's real package archs, so they stay right when a tune changes. MACHINE_SOCARCH is only
# set by fsl-dynamic-packagearch (i.MX machines), so it is left out when empty. Distros pick their feed with
# CARGT_FEED_RELEASE (e.g. cargt-imx-rt.conf).
CARGT_FEED_BASE ?= "https://yocto.cargt.com/linux-imx"
CARGT_FEED_RELEASE ?= "wrynose"
PACKAGE_FEED_URIS ?= "${CARGT_FEED_BASE}/${CARGT_FEED_RELEASE}"
PACKAGE_FEED_BASE_PATHS ?= ""
PACKAGE_FEED_ARCHS ?= "all ${TUNE_PKGARCH} ${@d.getVar('MACHINE_SOCARCH') or ''} ${MACHINE_ARCH}"
