require conf/distro/poky.conf

DISTRO = "imx-cargt"
DISTRO_NAME = "Cargt i.MX Release Distro"
DISTRO_VERSION = "6.6-scarthgap"
DISTROOVERRIDES = "fsl"

MAINTAINER = "Cargt <tim.carney@cargt.com>"

POKY_DEFAULT_DISTRO_FEATURES:remove = "${POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE}"
POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE             ?= "wayland"
POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE:mx6-nxp-bsp ?= "wayland vulkan"
POKY_DEFAULT_DISTRO_FEATURES_IMX_REMOVE:mx7-nxp-bsp ?= "wayland vulkan"
DISTRO_FEATURES:remove = "pulseaudio"

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
# assignment because meta-imx's fsl-imx-base.inc also sets it with ?=.
DEFAULTTUNE:mx8m-nxp-bsp = "cortexa53-crypto"
DEFAULTTUNE:mx8qm-nxp-bsp  ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8x-nxp-bsp   ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8ulp-nxp-bsp ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx9-nxp-bsp    ?= "armv8a-crc-crypto"
# i.MX91 builds with different DISTRO_FEATURES than i.MX93 (no wayland/opengl/
# vulkan, see below), so it must not share the armv8a package arch with i.MX93:
# the two machines would overwrite/delete each other's packages in the shared
# feed. cortexa55 matches meta-freescale's mx91 default. Hard assignment because
# meta-imx's fsl-imx-base.inc may also set DEFAULTTUNE:mx91-nxp-bsp with ?=.
DEFAULTTUNE:mx91-nxp-bsp = "cortexa55"

# These recipes are built differently on i.MX8MP (CAAM / ISP dependencies, jsoncpp epoch)
# but would otherwise be packaged for the shared armv8a arch, so i.MX8MP and i.MX93 builds
# delete each other's copies from the shared armv8a deploy dir/feed. Make them SoC-specific
# on i.MX8MP (armv8a-mx8mp, already in its PACKAGE_FEED_ARCHS).
MACHINE_SOCARCH_FILTER:append:mx8mp-nxp-bsp = " jsoncpp crypto-af-alg keyctl-caam smw"
DEFAULTTUNE:mx93-nxp-bsp   ?= "armv8a-crc-crypto"

PACKAGECONFIG:append:pn-gstreamer1.0-plugins-ugly = " x264"

PACKAGECONFIG:append:pn-perf = " jevents"

PACKAGECONFIG:append:pn-pulseaudio = " autospawn-for-root"

PACKAGECONFIG:append:class-target:pn-qtquick3d     = " examples"
PACKAGECONFIG:append:class-target:pn-qtwebengine   = " examples"

PACKAGECONFIG:append:pn-systemd = " unmanaged-network"

PACKAGECONFIG:append:mx93-nxp-bsp:pn-qtbase = " gles2"
PACKAGECONFIG:remove:mx93-nxp-bsp:pn-qtbase = "no-opengl linuxfb"

# i.MX 91 has no GPU or display — strip wayland/opengl/vulkan from this headless SoC
DISTRO_FEATURES:remove:mx91-nxp-bsp = "wayland opengl vulkan"
PACKAGECONFIG:remove:mx91-nxp-bsp:pn-qtbase = "gles2"
PACKAGECONFIG:append:mx91-nxp-bsp:pn-qtbase = " no-opengl linuxfb"

PACKAGECONFIG:append:pn-networkmanager = " modemmanager ppp"