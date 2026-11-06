SUMMARY = "Cargt development image with the NXP Real-time Edge userspace"
DESCRIPTION = "cargt-image-dev plus the Real-time Edge networking (TSN, PTP), \
industrial (EtherCAT, OPC UA, Modbus) and real-time test packages. Build with \
DISTRO = cargt-imx-rt for the PREEMPT_RT kernel."

# No debug-symbols rootfs by default (cargt-image-dev turns it on);
# IMAGE_GEN_DEBUGFS = "1" in local.conf still builds one.
IMAGE_GEN_DEBUGFS ?= "0"
require cargt-image-dev.bb

# The packagegroups come from meta-real-time-edge. packagegroup-real-time-edge-rtos
# is left out: it carries NXP EVK M-core demo binaries.
IMAGE_INSTALL += " \
    packagegroup-real-time-edge-networking \
    packagegroup-real-time-edge-system \
    packagegroup-real-time-edge-industrial \
    packagegroup-real-time-edge-tools \
    cargt-rt-check \
    cargt-rt-config \
"

export IMAGE_BASENAME = "cargt-image-rt"
