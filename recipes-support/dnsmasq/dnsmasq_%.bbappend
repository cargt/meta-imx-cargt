FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:"

# Only router machines (MACHINE_FEATURES "cargt-router", as in the linux-imx and
# ntp bbappends) run the standalone dnsmasq.service; none exist on wrynose yet.
# Everywhere else dnsmasq is installed only because NetworkManager's dnsmasq
# PACKAGECONFIG needs the binary for ipv4.method=shared, and the stock unit with
# the stock (all-commented) config binds 0.0.0.0:53 on every interface, so NM's
# own per-connection dnsmasq fails with "failed to create listening socket for
# <ip>: Address already in use".
SYSTEMD_AUTO_ENABLE:${PN} = "${@bb.utils.contains('MACHINE_FEATURES', 'cargt-router', 'enable', 'disable', d)}"
