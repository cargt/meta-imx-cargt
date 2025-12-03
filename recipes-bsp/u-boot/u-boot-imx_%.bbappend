FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0002-Add-support-for-imx93_00363.patch \
            file://0003-Update-u-boot-imx-to-boot-Cargt-Linux-image.patch \
            file://0004-Add-support-for-Cargt-00324-00326-SODIMM-SOM-on-carr.patch \
            file://0005-Autosave-env-when-defaults-are-set.patch \
            file://0006-Add-support-for-00377-00365.patch \
            "

SRC_URI:remove:imx8mp-cargt-00377-00365 = "file://0001-Add-Olimex-iMX8MP-SOM-EVB-IND.patch"
