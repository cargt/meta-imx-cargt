# Make RDP screen sharing work with use-g2d=true on rotated outputs. NXP's
# screen-share left the damage in global coordinates for G2D, so on a rotated
# panel the G2D readback failed and the RDP client got a black frame. This
# append is tied to the 15.0.1.imx version so a BSP update has to recheck it.
FILESEXTRAPATHS:prepend := "${THISDIR}/weston:"

SRC_URI += "file://0001-screen-share-transform-damage-to-output-coordinates-with-G2D.patch"
