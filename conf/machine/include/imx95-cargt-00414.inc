# Cargt i.MX 95 00414 OSM-L SOM: settings shared by every 00414 machine.

require conf/machine/include/imx95-cargt.inc

# 19x19 i.MX 95 with LPDDR5 and the EVK PMIC set (PF09 + PF5301 + PF5302).
#
# DDR init runs in OEI on the M33, using the Cargt cargt00414 board port
# (recipes-bsp/imx-oei) with every 00414 DDR configuration built in, from
# timing files exported from the NXP DDR Tool with PHY firmware FW2024.09
# (matches DDR_FIRMWARE_NAME below). OEI picks the configuration from the
# SOM EEPROM at boot, see recipes-bsp/imx-oei/imx-oei_%.bbappend.
OEI_BOARD = "cargt00414"
DDR_TYPE  = "lpddr5"
DDR_FIRMWARE_NAME = " \
    lpddr5_dmem_v202409.bin \
    lpddr5_dmem_qb_v202409.bin \
    lpddr5_imem_v202409.bin \
    lpddr5_imem_qb_v202409.bin \
"
# imx-oei passes DDR_CONFIG to make; boards/cargt00414 ignores it and builds
# every configuration listed in CARGT_OEI_00414_TIMINGS.
OEI_DDR_CONFIG = "cargt00414_MT62F512M32D2DR_2GB_6400MTS_FW2024.09_timing"
# No inline-ECC timing exists for the 00414, but imx-oei references this
# variable unconditionally when building DDR_CONFIG, so it must be defined.
OEI_DDR_CONFIG_ECC = "${OEI_DDR_CONFIG}"

# The 00414 boots from eMMC or SD and U-Boot keeps its environment on the
# boot MMC, so fw_env.config must follow the boot device (libubootenv).
MACHINE_FEATURES:append = " fw-env-bootdev"

# SM board port and resource config (recipes-bsp/imx-system-manager)
SYSTEM_MANAGER_CONFIG = "mx95cargt00414"
