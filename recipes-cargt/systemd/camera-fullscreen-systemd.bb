LICENSE = "CLOSED"
inherit systemd

DESCRIPTION = "Camera fullscreen display service using GStreamer"
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "camera-fullscreen.service"

RDEPENDS:${PN} = "bash \
                  gstreamer1.0 \
                  gstreamer1.0-plugins-base \
                  gstreamer1.0-plugins-good \
                  isp-imx \
                  weston \
                  "

SRC_URI:append = " file://camera-fullscreen.service \
                   file://camera-fullscreen.sh \
                   "

FILES:${PN} = "${systemd_unitdir}/system/camera-fullscreen.service \
               ${bindir}/camera-fullscreen.sh \
               "

do_install() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/camera-fullscreen.service ${D}/${systemd_unitdir}/system

  install -d ${D}/${bindir}
  install -m 0755 ${WORKDIR}/camera-fullscreen.sh ${D}/${bindir}
}
