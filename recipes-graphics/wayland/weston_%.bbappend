# Build Weston's RDP backend (rdp-backend.so) on every i.MX machine. The
# images already ship the [screen-share] section of weston.ini, whose
# command runs weston --backend=rdp-backend.so, but meta-imx's weston recipe
# leaves PACKAGECONFIG[rdp] off, so screen sharing had no backend. Building
# it everywhere, not only on machines with the rdp MACHINE_FEATURE, keeps
# Weston identical across machines of a SoC family, so they share one build
# from the sstate cache. Whether a machine uses it is up to weston-init
# (MACHINE_FEATURES rdp). Weston 15 builds against the freerdp 2.x server
# libraries in meta-oe.
#
# Size cost: PACKAGECONFIG[rdp] makes weston RDEPEND on freerdp, so every
# image with Weston now ships freerdp, even on machines without the rdp
# feature: about 5.2 MiB for the freerdp and winpr libraries and the xfreerdp
# client, plus 0.13 MiB for rdp-backend.so in libweston-15. An image without
# cups, avahi, libusb, xkbfile and a few X11 libraries gains up to 1.5 MiB more
# for them. The Cargt dev and chrome images on rdp machines already ship
# freerdp, so they grow only by the backend.
PACKAGECONFIG:append = " rdp"
