SUMMARY = "Cargt development image with the NXP Real-time Edge userspace"
DESCRIPTION = "cargt-image-dev plus the Real-time Edge networking (TSN, PTP), \
industrial (EtherCAT, OPC UA, Modbus) and real-time test packages. Build with \
DISTRO = cargt-imx-rt for the PREEMPT_RT kernel."

require cargt-image-dev.bb

# The packagegroups come from meta-real-time-edge. packagegroup-real-time-edge-rtos
# is left out: it carries NXP EVK M-core demo binaries.
IMAGE_INSTALL += " \
    packagegroup-real-time-edge-networking \
    packagegroup-real-time-edge-system \
    packagegroup-real-time-edge-industrial \
    packagegroup-real-time-edge-tools \
    cargt-rt-check \
"

export IMAGE_BASENAME = "cargt-image-rt"
