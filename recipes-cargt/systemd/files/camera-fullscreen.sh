#!/bin/bash
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/run/user/0
sleep 3
exec gst-launch-1.0 -v v4l2src device=/dev/video0 io-mode=mmap ! "video/x-raw,format=YUY2,width=1920,height=1080,framerate=30/1" ! queue ! imxvideoconvert_g2d ! waylandsink fullscreen=true sync=false
