#!/bin/sh
#
# Cargt i.MX Yocto Project Build Environment Setup Script
#
# MIT License
# Copyright 2025 Cargt

if [ ! -n "$MACHINE" ]; then
    MACHINE=imx93-cargt-00363-00365
fi
echo "MACHINE = $MACHINE"

if [ ! -n "$DISTRO" ]; then
    DISTRO=cargt-imx-xwayland
fi
echo "DISTRO = $DISTRO"

EULA=$EULA DISTRO=$DISTRO MACHINE=$MACHINE . ./imx-setup-release.sh $@

echo "# layers for Cargt i.MX" >> conf/bblayers.conf
echo "BBLAYERS += \"\${BSPDIR}/sources/meta-browser/meta-chromium\"" >> conf/bblayers.conf
echo "BBLAYERS += \"\${BSPDIR}/sources/meta-imx-cargt\"" >> conf/bblayers.conf
echo "BBLAYERS += \"\${BSPDIR}/sources/meta-swupdate\"" >> conf/bblayers.conf

# NXP Real-time Edge layers for the PREEMPT_RT distro. Kept out of other builds:
# meta-real-time-edge also patches ATF, imx-mkimage, linuxptp, iproute2 and lldpd.
if [ "$DISTRO" = "cargt-imx-rt" ]; then
    echo "BBLAYERS += \"\${BSPDIR}/sources/meta-rtos-industrial\"" >> conf/bblayers.conf
    echo "BBLAYERS += \"\${BSPDIR}/sources/meta-real-time-edge\"" >> conf/bblayers.conf
fi

echo ""
echo "Cargt i.MX setup complete and it can generate Yocto images now."
