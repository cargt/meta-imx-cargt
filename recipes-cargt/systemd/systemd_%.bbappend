# Cargt networkd configuration is machine-specific, so it lives in its own
# MACHINE_ARCH package; systemd itself stays identical for every machine.
RRECOMMENDS:${PN}:append:class-target = " cargt-network-config"
