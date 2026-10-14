# stress-ng only builds its GPU stressor (--gpu, EGL + GLES2 on GBM) when
# those libraries are found at configure time, and the OE-core recipe does
# not depend on them. Add the Mali EGL/GLES2/GBM providers on i.MX 95.
DEPENDS:append:mx95-nxp-bsp = " virtual/egl virtual/libgles2 virtual/libgbm"

# The Mali GBM ("armsoc") cannot create a linear surface; let the gpu
# stressor fall back to a non-linear one.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append:mx95-nxp-bsp = " file://0001-stress-gpu-retry-gbm-surface-without-GBM_BO_USE_LINEAR.patch"
