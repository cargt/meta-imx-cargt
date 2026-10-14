# Cargt i.MX 95 00414 OSM-L SOM: settings shared by every 00414 machine.

require conf/machine/include/imx95-cargt.inc

# 19x19 i.MX 95 with LPDDR5 and the EVK PMIC set (PF09 + PF5301 + PF5302).
#
# DDR init runs in OEI on the M33, using the Cargt cargt00414 board port
# (recipes-bsp/imx-oei) and a timing file exported from the NXP DDR Tool
# with PHY firmware FW2024.09 (matches DDR_FIRMWARE_NAME below). Only one
# DDR part is fitted today: MT62F512M32D2DR-031 WT:B (2 GB, 6400 MT/s).
OEI_BOARD = "cargt00414"
DDR_TYPE  = "lpddr5"
DDR_FIRMWARE_NAME = " \
    lpddr5_dmem_v202409.bin \
    lpddr5_dmem_qb_v202409.bin \
    lpddr5_imem_v202409.bin \
    lpddr5_imem_qb_v202409.bin \
"
OEI_DDR_CONFIG = "cargt00414_MT62F512M32D2DR_2GB_6400MTS_FW2024.09_timing"
# No inline-ECC timing exists for the 00414, but imx-oei references this
# variable unconditionally when building DDR_CONFIG, so it must be defined.
OEI_DDR_CONFIG_ECC = "${OEI_DDR_CONFIG}"

# SM board port and resource config (recipes-bsp/imx-system-manager)
SYSTEM_MANAGER_CONFIG = "mx95cargt00414"
