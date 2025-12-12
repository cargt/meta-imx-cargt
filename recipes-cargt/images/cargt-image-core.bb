LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \    
    ${@bb.utils.contains('MACHINE_FEATURES', 'squashfs', 'read-only-rootfs','', d)} \
    debug-tweaks \
    tools-profile \
    tools-sdk \
    package-management \
    nfs-server \
    tools-debug \
    ssh-server-openssh \
    hwcodecs \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston','', d)} \
    empty-root-password serial-autologin-root \
"

SDKIMAGE_FEATURES:append = " \
    staticdev-pkgs \
"

IMAGE_INSTALL += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland xterm', '', d)} \
    imx-test \
    firmwared \
    packagegroup-imx-core-tools \
    packagegroup-imx-security \
    curl \
    ${CLINFO} \
    kernel-image \
	kernel-devicetree \
    util-linux \
    util-linux-lsblk \
    iperf3 \
    can-utils \
    i2c-tools \
    ppp modemmanager \
    ${@bb.utils.contains('MACHINE_FEATURES', 'morsemicro', 'morsemicro-driver morsemicro-firmware morse-ctrl', 'nxp-wifi-systemd nxp-bluetooth-systemd', d)} \
    u-boot-fw-utils \
    mosquitto \
    libiio-tests \
    ${@bb.utils.contains('DISTRO_FEATURES', 'connman', 'connman-tools connman-tests connman-client', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'networkmanager', 'networkmanager networkmanager-nmcli', '', d)} \
    swupdate swupdate-progress swupdate-www \
    board-version \
"

CLINFO              ?= ""
CLINFO:imxgpu        = "clinfo"
CLINFO:mx8mm-nxp-bsp = ""
CLINFO:mx7-nxp-bsp   = ""

DOCKER            ?= ""
DOCKER:mx8-nxp-bsp = "docker"

export IMAGE_BASENAME = "cargt-image-core"

ROOTFS_POSTPROCESS_COMMAND:append = "nfs_symlink; "
nfs_symlink() {
    ln -fs ${IMAGE_ROOTFS} ${TMPDIR}/../rootfs
}




