FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# viv_find_compatible_nodes() in vvcam/v4l2/video/video.c left a missing
# devicetree "id" property at its -1 sentinel with no bounds check for
# negative values, causing an out-of-bounds file_list_lock[-1]/vdev->id
# access (and a kernel crash) whenever an ISP-compatible node is enabled
# without an explicit "id" -- hit on imx8mp-cargt-00377-00365's
# -glt1011280800is1 and -hdmi variants (both pull in
# imx8mp-cargt-00377-00365-os08a20.dtsi, which enables &isp_0 with no id
# set). See the patch itself for the full root-cause writeup.
SRC_URI += "file://0001-v4l2-video-fix-negative-array-index-when-ISP-node-l.patch"
