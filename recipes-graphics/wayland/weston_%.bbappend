# Build Weston's RDP backend (rdp-backend.so) on every i.MX machine. The
# images already ship the [screen-share] section of weston.ini, whose
# command runs weston --backend=rdp-backend.so, but meta-imx's weston recipe
# leaves PACKAGECONFIG[rdp] off, so screen sharing had no backend. Building
# it everywhere, not only on machines with the rdp MACHINE_FEATURE, keeps
# Weston identical across machines of a SoC family, so they share one build
# from the sstate cache. Whether a machine uses it is up to weston-init
# (MACHINE_FEATURES rdp). Weston 15 builds against the freerdp 2.x server
# libraries in meta-oe.
PACKAGECONFIG:append = " rdp"
