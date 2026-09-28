require conf/machine/include/imx-base.inc
require conf/machine/include/arm/armv8-2a/tune-cortexa55.inc

MACHINE_FEATURES += "pci gpu"
MACHINE_FEATURES:append:use-nxp-bsp = " optee"

IMX_DEFAULT_BOOTLOADER:use-nxp-bsp = "u-boot-imx"
IMX_DEFAULT_BOOTLOADER:use-mainline-bsp = "u-boot-fslc"

LOADADDR = ""
UBOOT_SUFFIX = "bin"
UBOOT_MAKE_TARGET = ""

SPL_BINARY = "spl/u-boot-spl.bin"

UBOOT_CONFIG ??= "sd"
UBOOT_CONFIG[sd]   = "${UBOOT_CONFIG_BASENAME}_defconfig"
UBOOT_CONFIG_IMAGE_FSTYPES[sd] = "sdcard"

# Set ATF platform name
ATF_PLATFORM = "imx95"

# i.MX 95 boot flow: ROM -> OEI (DDR init, on the M33) -> System Manager
# (M33) -> SPL/ATF/OP-TEE/U-Boot on the A55.
OEI_CORE = "m33"
OEI_SOC  = "mx95"

# A55-only boot container (no M7 image). imx-boot's mx95 do_compile still
# copies ${M4_DEFAULT_IMAGE} unconditionally, so point it at a stock
# imx-m7-demos binary; it is not packed into the flash_a55 container.
IMXBOOT_TARGETS = "flash_a55"
M4_DEFAULT_IMAGE_MX95 = "imx95-19x19-evk_m7_TCM_hello_world.bin"

IMX_BOOT_SOC_TARGET = "iMX95"
IMX_BOOT_SEEK = "32"

# We have to disable SERIAL_CONSOLE due to auto-serial-console
SERIAL_CONSOLES = "115200;ttyLP0"

IMX_DEFAULT_BSP = "nxp"
