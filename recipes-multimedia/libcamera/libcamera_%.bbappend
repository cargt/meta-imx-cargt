# Prefer the NXP NEO ISP pipeline handler over the raw-only ISI one.
#
# On i.MX 95 both the nxp/neo and imx8-isi pipeline handlers can claim a
# sensor behind the ISI, and libcamera tries them in registration order, so
# imx8-isi wins and applications only get raw Bayer. nxp/neo runs the sensor
# through the NEO ISP with the tuning files in ${datadir}/libcamera/ipa/nxp/neo
# and gives NV12, YUYV and RGB.
#
# libcamera reads pipelines_match_list from /etc/libcamera/configuration.yaml in
# every process (login shells, systemd services, Weston clients, gst-launch),
# with no environment to set up. The list keeps every built pipeline handler,
# with nxp/neo first, so the others still match cameras nxp/neo does not handle
# (USB cameras through uvcvideo, other SoCs). LIBCAMERA_PIPELINES_MATCH_LIST
# still overrides it, e.g. LIBCAMERA_PIPELINES_MATCH_LIST=imx8-isi for raw.
CARGT_LIBCAMERA_PREFERRED_PIPELINES ?= "nxp/neo"

do_install:append() {
    preferred=""
    for p in ${CARGT_LIBCAMERA_PREFERRED_PIPELINES}; do
        case ",${LIBCAMERA_PIPELINES}," in *",$p,"*) preferred="$preferred $p" ;; esac
    done
    if [ -n "$preferred" ]; then
        install -d ${D}${sysconfdir}/libcamera
        conf=${D}${sysconfdir}/libcamera/configuration.yaml
        printf '%%YAML 1.1\n---\nversion: 1\nconfiguration:\n  pipelines_match_list:\n' > $conf
        for p in $preferred $(echo "${LIBCAMERA_PIPELINES}" | tr ',' ' '); do
            grep -qxF "    - $p" $conf || echo "    - $p" >> $conf
        done
    fi
}

CONFFILES:${PN} += "${sysconfdir}/libcamera/configuration.yaml"
