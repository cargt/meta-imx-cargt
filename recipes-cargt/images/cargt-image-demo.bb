LICENSE = "MIT"

require recipes-cargt/images/cargt-image-dev.bb


IMAGE_INSTALL += " \
    lvgl-2048-demo-1280x800 \
    lvgl-smartappliance-demo-1280x800 \
    chromium-ozone-wayland \
    "

export IMAGE_BASENAME = "cargt-image-demo"

ROOTFS_POSTPROCESS_COMMAND:append = "install_launchers; "

install_launchers() {
    printf "\n[launcher]\nicon=/usr/share/weston/terminal.png\npath=/usr/bin/weston-terminal" >> ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini    
    if ! grep -q "icon=/usr/share/weston/icon/lvgl-2048-demo-1280x800.png" ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    then
       printf "\n[launcher]\nicon=/usr/share/weston/icon/lvgl-2048-demo-1280x800.png\npath=QMLSCENE_DEVICE=softwarecontext /usr/bin/lvgl-2048-demo-1280x800\n\n" >> ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini    
    fi
    if ! grep -q "icon=/usr/share/weston/icon/lvgl-smartappliance-demo-1280x800.png" ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    then
       printf "\n[launcher]\nicon=/usr/share/weston/icon/lvgl-smartappliance-demo-1280x800.png\npath=QMLSCENE_DEVICE=softwarecontext /usr/bin/lvgl-smartappliance-demo-1280x800\n\n" >> ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    fi    
    if ! grep -q "icon=/usr/share/weston/icon/chromium.png" ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    then
       printf "\n[launcher]\nicon=/usr/share/weston/icon/chromium.png\npath=QMLSCENE_DEVICE=softwarecontext /usr/lib/chromium//chromium-bin --use-gl=egl --ozone-platform=wayland --disable-features=VizDisplayCompositor --no-sandbox\n\n" >> ${IMAGE_ROOTFS}${sysconfdir}/xdg/weston/weston.ini
    fi    
    if ! grep -q "HOME=/root/" ${IMAGE_ROOTFS}${sysconfdir}/default/weston
    then
        printf "\nHOME=/root/\nQT_QPA_PLATFORM=wayland" >> ${IMAGE_ROOTFS}${sysconfdir}/default/weston
    fi
}

ROOTFS_POSTPROCESS_COMMAND:append = "nfs_symlink; "
nfs_symlink() {
    ln -fs ${IMAGE_ROOTFS} ${TMPDIR}/../rootfs
}