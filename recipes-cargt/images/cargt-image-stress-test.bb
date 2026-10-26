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
