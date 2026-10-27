SUMMARY = "cargt-image-chrome with CPU, RAM, GPU, NPU and storage load tools, for thermal and stress testing"
LICENSE = "MIT"

require recipes-cargt/images/cargt-image-chrome.bb

export IMAGE_BASENAME = "cargt-image-stress-test"

# CPU and RAM (stress-ng, memtester) and storage (fio); Chromium and the
# GStreamer VPU plugins come from cargt-image-chrome
IMAGE_INSTALL:append = " stress-ng memtester fio"

# GPU (SoCs with a 3D GPU: i.MX 95, i.MX 8M Plus)
IMAGE_INSTALL:append:imxgpu3d = " glmark2"

# TensorFlow Lite (with benchmark_model and label_image) and each SoC's NPU
# delegate, as in meta-imx-ml's packagegroup-imx-ml
IMAGE_INSTALL:append = " tensorflow-lite"
IMAGE_INSTALL:append:mx95-nxp-bsp = " tensorflow-lite-neutron-delegate neutron eiq-examples-npu-utils"
IMAGE_INSTALL:append:mx93-nxp-bsp = " tensorflow-lite-ethosu-delegate ethos-u-driver-stack"
IMAGE_INSTALL:append:mx8mp-nxp-bsp = " tensorflow-lite-vx-delegate"

# Keep Weston running on a board with no display connected (a headless DT, or
# HDMI with no monitor): by default it exits when it has no output, which
# leaves glmark2 nothing to run on. glmark2 --off-screen needs no output, but
# video (waylandsink) and the Chromium kiosk do: for those, force one on the
# kernel command line, e.g. fw_setenv cargt_bootargs video=HDMI-A-1:1920x1080@60e
ROOTFS_POSTPROCESS_COMMAND:append = "weston_require_no_outputs; "

weston_require_no_outputs() {
    if [ -f ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini ] && \
       ! grep -q "^require-outputs=" ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    then
        sed -i 's/^\[core\]$/[core]\nrequire-outputs=none/' ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    fi
}

# The i.MX 91 has no GPU and will not drive a display: leave out Chromium,
# which is built per SoC and takes hours, and its Weston launcher
CORE_IMAGE_EXTRA_INSTALL:remove:mx91-nxp-bsp = "chromium-ozone-wayland"
ROOTFS_POSTPROCESS_COMMAND:append:mx91-nxp-bsp = "remove_chromium_launcher; "

remove_chromium_launcher() {
    if [ -f ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini ]; then
        sed -i '/^\[launcher\]$/{N;/chromium\.png/{N;d}}' ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    fi
}
