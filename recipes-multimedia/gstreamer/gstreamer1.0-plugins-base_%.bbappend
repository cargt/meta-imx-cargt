# GPU rotation and transforms in GStreamer: the opengl plugin only builds
# glvideoflip and gltransformation when graphene (a small MIT vector/matrix
# library depending only on glib) is found. Only on SoCs with a 3D GPU, where
# the opengl plugin is built (i.MX 8M Plus, i.MX 95).
#
# On i.MX 95 both need glcolorconvert in front of them (NV12 straight from
# glupload does not negotiate). For a 1080p camera, gltransformation
# rotation-z=180 runs at about 60 fps, the same as imxvideoconvert_g2d
# rotation, while glvideoflip only reaches about 22 fps.
PACKAGECONFIG:append:imxgpu3d = " graphene"
