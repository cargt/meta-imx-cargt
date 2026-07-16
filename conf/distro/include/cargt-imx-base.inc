require conf/distro/poky.conf

DISTRO = "imx-cargt"
DISTRO_NAME = "Cargt i.MX Release Distro"
DISTRO_VERSION = "6.18-wrynose"
DISTROOVERRIDES = "fsl"

# Pin u-boot to the scarthgap-era version (vendored into meta-imx-cargt as
# u-boot-imx_2024.04.bb, since wrynose's meta-imx-bsp only ships 2026.04) so
# u-boot bring-up is isolated from the wrynose migration until the kernel is
# validated. Remove this pin (and the vendored recipe) once ready to move
# u-boot to 2026.04.
PREFERRED_VERSION_u-boot-imx = "2024.04"

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
DEFAULTTUNE:mx8m-nxp-bsp   ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8qm-nxp-bsp  ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8x-nxp-bsp   ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx8ulp-nxp-bsp ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx9-nxp-bsp    ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx91-nxp-bsp  ?= "armv8a-crc-crypto"
DEFAULTTUNE:mx93-nxp-bsp   ?= "armv8a-crc-crypto"

PACKAGECONFIG:append:pn-gstreamer1.0-plugins-ugly = " x264"

PACKAGECONFIG:append:pn-perf = " jevents"

PACKAGECONFIG:append:pn-pulseaudio = " autospawn-for-root"

PACKAGECONFIG:append:class-target:pn-qtquick3d     = " examples"
PACKAGECONFIG:append:class-target:pn-qtwebengine   = " examples"

PACKAGECONFIG:append:mx93-nxp-bsp:pn-qtbase = " gles2"
PACKAGECONFIG:remove:mx93-nxp-bsp:pn-qtbase = "no-opengl linuxfb"

# i.MX 91 has no GPU or display — strip wayland/opengl/vulkan from this headless SoC
DISTRO_FEATURES:remove:mx91-nxp-bsp = "wayland opengl vulkan"
PACKAGECONFIG:remove:mx91-nxp-bsp:pn-qtbase = "gles2"
PACKAGECONFIG:append:mx91-nxp-bsp:pn-qtbase = " no-opengl linuxfb"

PACKAGECONFIG:append:pn-networkmanager = " modemmanager ppp"