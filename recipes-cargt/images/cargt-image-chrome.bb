LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \    
    ${@bb.utils.contains('MACHINE_FEATURES', 'squashfs', 'read-only-rootfs','', d)} \
    debug-tweaks \
    tools-profile \
    tools-sdk \
    package-management \
    splash \
    nfs-server \
    tools-debug \
    ssh-server-openssh \
    hwcodecs \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston','', d)} \
"

SDKIMAGE_FEATURES:append = " \
    staticdev-pkgs \
"

CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-core-full-cmdline \
    packagegroup-fsl-tools-gpu \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland xterm', '', d)} \
    packagegroup-fsl-gstreamer1.0 \
    packagegroup-fsl-gstreamer1.0-full \
    chromium-ozone-wayland \
"

IMAGE_INSTALL += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland xterm', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'linux-imx-signature imx-boot-signature u-boot-imx-signature', '','kernel-image kernel-devicetree ', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'lora', 'sx1302-hal lora-packet-forwarder-systemd','', d)} \
    imx-test \
    firmwared \
    packagegroup-imx-core-tools \
    packagegroup-imx-security \
    curl \
    ${CLINFO} \
    util-linux \
    util-linux-lsblk \
    iperf3 \
    can-utils \
    i2c-tools \
    ppp modemmanager \
    u-boot-fw-utils \
    mosquitto \
    libiio-tests \
    tmux \
    mc \
    vim \
    git \
    ${@bb.utils.contains('DISTRO_FEATURES', 'connman', 'connman-tools connman-tests connman-client', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'networkmanager', 'networkmanager networkmanager-nmcli', '', d)} \
    dtc \
    libiio libiio-tests \
    packagegroup-core-buildessential \
    kernel-modules \
    kernel-dev \
    kernel-devsrc \
    libp11 opensc openssl-bin \
    ${@bb.utils.contains('MACHINE_FEATURES', 'morsemicro', 'morsemicro-driver morsemicro-firmware morse-ctrl', 'nxp-wifi-systemd nxp-bluetooth-systemd', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'rdp', 'freerdp', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'vnc', 'neatvnc', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'nfc-click', 'libnfc-nci-linux', '', d)} \
    teleport \
    swupdate swupdate-progress swupdate-www \
    board-version \
    v4l-utils \
"

CLINFO              ?= ""
CLINFO:imxgpu        = "clinfo"
CLINFO:mx8mm-nxp-bsp = ""
CLINFO:mx7-nxp-bsp   = ""

DOCKER            ?= ""
DOCKER:mx8-nxp-bsp = "docker"

export IMAGE_BASENAME = "cargt-image-chrome"

ROOTFS_POSTPROCESS_COMMAND:append = "nfs_symlink; "
nfs_symlink() {
    ln -fs ${IMAGE_ROOTFS} ${TMPDIR}/../rootfs
}




