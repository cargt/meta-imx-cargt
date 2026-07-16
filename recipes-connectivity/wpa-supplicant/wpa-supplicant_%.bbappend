FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# NetworkManager's wifi backend requires wpa_supplicant's D-Bus control interface
# (fi.w1.wpa_supplicant1) to manage devices; without it NetworkManager logs "Failed
# to D-Bus activate wpa_supplicant service" and every wifi device stays "unavailable".
# On imx-nxp-bsp machines, meta-imx-sdk's own wpa-supplicant_%.bbappend swaps SRC_URI
# for NXP's own mirrored source + defconfig (do_configure:append:imx-nxp-bsp copies
# wpa_supplicant/defconfig to .config), and that defconfig ships with
# CONFIG_CTRL_IFACE_DBUS_NEW commented out. The only existing fix for this in the tree
# is this same patch, vendored from meta-nxp-connectivity/meta-nxp-matter-advanced (a
# much larger Matter/Thread demo layer that isn't included in this build) -- copied
# here instead of pulling in that whole layer for one defconfig patch.
SRC_URI:append:imx-nxp-bsp = " file://0001-Enable-the-DBUS-for-wpa-supplicant.patch"
