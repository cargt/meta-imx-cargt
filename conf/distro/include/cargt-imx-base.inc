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
DEFAULTTUNE:mx8m-nxp-bsp   ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8qm-nxp-bsp  ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8x-nxp-bsp   ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8ulp-nxp-bsp ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx9-nxp-bsp    ?= "armv8a-crc-crypto"
# i.MX91 builds with different DISTRO_FEATURES than i.MX93 (no x11/vulkan, see
# below), so it must not share the armv8a package arch with i.MX93: the two
# machines would overwrite/delete each other's packages in the shared feed.
# cortexa55 matches meta-freescale's mx91 default. Hard assignment because
# meta-imx's fsl-imx-base.inc also sets DEFAULTTUNE:mx91-nxp-bsp with ?=.
DEFAULTTUNE:mx91-nxp-bsp = "cortexa55"

# These recipes are built differently on i.MX8MP (CAAM / ISP dependencies, jsoncpp epoch)
# but would otherwise be packaged for the shared armv8a arch, so i.MX8MP and i.MX93 builds
# delete each other's copies from the shared armv8a deploy dir/feed. Make them SoC-specific
# on i.MX8MP (armv8a-mx8mp, already in its PACKAGE_FEED_ARCHS).
MACHINE_SOCARCH_FILTER:append:mx8mp-nxp-bsp = " jsoncpp crypto-af-alg keyctl-caam smw"
DEFAULTTUNE:mx93-nxp-bsp   ?= "armv8a-crc-crypto"
# imx-base.inc sets DEFAULTTUNE:mx95-generic-bsp ?= "cortexa55", which comes
# after mx9-nxp-bsp in OVERRIDES and would otherwise win.
# i.MX95 has a GPU (Mali) and other machine features than i.MX93/8MP, so it must not share the
# armv8a package arch with them: the machines would overwrite/delete each other's packages in the
# shared armv8a deploy dir/feed. armv8-2a-crypto packages as "armv8-2a", used by no other Cargt SoC
# (imx93/imx8mp: armv8a, imx91: cortexa55). Hard assignment: imx-base.inc also sets mx95 with ?=.
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

# i.MX 91 has no GPU, so vulkan is always stripped, and x11 along with it
# since weston-xwayland requires opengl. Most i.MX 91 boards are also headless,
# so wayland/opengl are stripped too -- except imx91-cargt-00363-00365, which
# supports the 00379 MikroBus SPI display via tinydrm/DRM-KMS. Weston itself is
# unconditionally gated on the opengl DISTRO_FEATURE upstream (it always
# DEPENDS on virtual/egl, even when actually rendering via pixman at runtime),
# so opengl stays enabled there too -- satisfied by Mesa's llvmpipe software
# rasterizer, not real GPU hardware (there still isn't any on this SoC).
DISTRO_FEATURES:remove:mx91-nxp-bsp = "${@bb.utils.contains('MACHINE', 'imx91-cargt-00363-00365', 'vulkan x11', 'wayland opengl vulkan x11', d)}"
PACKAGECONFIG:remove:mx91-nxp-bsp:pn-qtbase = "gles2"
PACKAGECONFIG:append:mx91-nxp-bsp:pn-qtbase = " no-opengl linuxfb"

PACKAGECONFIG:append:pn-networkmanager = " modemmanager ppp"