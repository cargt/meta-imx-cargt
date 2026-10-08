# Cargt i.MX 95 00414 OSM-L SOM OEI (DDR init) board port.
#
# boards/cargt00414 is a copy of boards/mx95lp5 (same PMIC and 19x19 LPDDR5
# layout) taken from the fetched source at build time, minus the EVK
# timing files. The 00414 timing file(s) exported from the NXP DDR Tool
# live in this layer and are copied into boards/cargt00414/ddr/; the patch
# holds the board deltas. Selected with OEI_BOARD = "cargt00414".
#
# Only one DDR part is fitted today (MT62F512M32D2DR, 2 GB). Supporting
# several parts from one image (part read from the SOM EEPROM) is tracked
# in docs/imx95-00414-bringup.md: a second full timing table does not fit
# next to the training firmware, so it needs a base table + per-part deltas.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

CARGT_OEI_00414 = "${@'1' if d.getVar('OEI_BOARD') == 'cargt00414' else ''}"

CARGT_OEI_00414_TIMINGS = "cargt00414_MT62F512M32D2DR_2GB_6400MTS_FW2024.09_timing.c"

SRC_URI:append = "${@' file://0001-boards-cargt00414-Cargt-i.MX-95-00414-OSM-L-SOM.patch ' + \
    ' '.join('file://' + f for f in d.getVar('CARGT_OEI_00414_TIMINGS').split()) \
    if d.getVar('CARGT_OEI_00414') else ''}"

do_patch[prefuncs] += "${@'oei_create_cargt00414_board' if d.getVar('CARGT_OEI_00414') else ''}"

oei_create_cargt00414_board() {
    rm -rf ${S}/boards/cargt00414
    cp -a ${S}/boards/mx95lp5 ${S}/boards/cargt00414
    rm -f ${S}/boards/cargt00414/ddr/*.c
}

do_configure:prepend() {
    if [ -n "${CARGT_OEI_00414}" ]; then
        for f in ${CARGT_OEI_00414_TIMINGS}; do
            cp ${UNPACKDIR}/$f ${S}/boards/cargt00414/ddr/
        done
    fi
}
