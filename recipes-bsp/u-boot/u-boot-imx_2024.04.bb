# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2018 (C) O.S. Systems Software LTDA.
# Copyright 2017-2024 NXP
#
# Vendored into meta-imx-cargt (2026-07-16): this recipe no longer exists in
# wrynose's meta-imx-bsp (NXP moved to u-boot-imx_2026.04.bb). Kept here,
# pinned via PREFERRED_VERSION_u-boot-imx, to isolate u-boot from the
# scarthgap->wrynose migration while kernel bring-up is validated first.
# Sourced from meta-imx-bsp at tag rel_imx_6.6.36_2.1.0 (cargt's own
# scarthgap pin). Remove once u-boot is upgraded to 2026.04.

require recipes-bsp/u-boot/u-boot.inc
require u-boot-imx-common_${PV}.inc

PROVIDES += "u-boot"

inherit uuu_bootloader_tag

UUU_BOOTLOADER                        = ""
UUU_BOOTLOADER:mx6-generic-bsp        = "${UBOOT_BINARY}"
UUU_BOOTLOADER:mx7-generic-bsp        = "${UBOOT_BINARY}"
# The UUU tag goes on the boot partition. For 8+, the boot partition image
# is imx-boot (built by the separate imx-boot recipe, not this one), so
# disable UUU-tagging here — matches the fix NXP made in u-boot-imx_2026.04.bb;
# without it, uuu_bootloader_tag's do_deploy:append tries to tag a file named
# "imx-boot" that this recipe never produces, and do_deploy fails.
UUU_BOOTLOADER:mx8-generic-bsp        = ""
UUU_BOOTLOADER:mx9-generic-bsp        = ""
UUU_BOOTLOADER_TAGGED                 = ""
UUU_BOOTLOADER_TAGGED:mx6-generic-bsp = "u-boot-tagged.${UBOOT_SUFFIX}"
UUU_BOOTLOADER_TAGGED:mx7-generic-bsp = "u-boot-tagged.${UBOOT_SUFFIX}"
UUU_BOOTLOADER_UNTAGGED                 = ""
UUU_BOOTLOADER_UNTAGGED:mx6-generic-bsp = "u-boot-untagged.${UBOOT_SUFFIX}"
UUU_BOOTLOADER_UNTAGGED:mx7-generic-bsp = "u-boot-untagged.${UBOOT_SUFFIX}"

do_deploy:append:mx8m-generic-bsp() {
    # Deploy u-boot-nodtb.bin and fsl-imx8m*-XX.dtb for mkimage to generate boot binary
    if [ -n "${UBOOT_CONFIG}" ]
    then
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    install -d ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/arch/arm/dts/${UBOOT_DTB_NAME}  ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/u-boot-nodtb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${type}
                fi
            done
            unset  j
        done
        unset  i
    fi

    # Deploy CRT.* from u-boot for stmm
    install -m 0644 ${S}/CRT.*     ${DEPLOYDIR}
}

do_deploy:append:mx93-generic-bsp() {
    # Deploy CRT.* from u-boot for stmm
    install -m 0644 ${S}/CRT.*     ${DEPLOYDIR}
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6-generic-bsp|mx7-generic-bsp|mx8-generic-bsp|mx9-generic-bsp)"
