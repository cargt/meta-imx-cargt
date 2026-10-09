# Cargt i.MX 95 00414 OSM-L SOM OEI (DDR init) board port.
#
# boards/cargt00414 is a copy of boards/mx95lp5 (same PMIC and 19x19 LPDDR5
# layout) taken from the fetched source at build time, minus the EVK
# timing files. Selected with OEI_BOARD = "cargt00414".
#
# One OEI image supports every DRAM part fitted on the 00414. At boot OEI
# reads the DDR configuration ID from the SOM EEPROM (M24C02 at 0x50 on
# LPI2C1, before the System Manager owns the bus) and trains that
# configuration; with a blank or unknown EEPROM it tries every
# configuration in turn (patches 0001, 0002).
#
# The DDR Tool timing files below are the source of truth. They must be
# generated from the 00414 DDR Tool project, which carries the 00414 CA/DQ
# bus mapping. At build time scripts/cargt_ddr_merge.py (patch 0003) turns
# them into one shared trained-CSR list and PIE table plus a small file per
# configuration, since two full LPDDR5 tables do not fit next to the
# training firmware. Each entry is <name>:<file>; the name must match
# CARGT_DDR_TIMINGS and cargt_ddr_cfgs.c in boards/cargt00414/ddr (patch
# 0004), and the first entry provides the shared tables.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

CARGT_OEI_00414 = "${@'1' if d.getVar('OEI_BOARD') == 'cargt00414' else ''}"

CARGT_OEI_00414_TIMINGS = " \
    MT62F4G32D8DV_16GB:cargt00414_MT62F4G32D8DV_16GB_6400MTS_FW2024.09_timing.c \
    MT62F512M32D2DR_2GB:cargt00414_MT62F512M32D2DR_2GB_6400MTS_FW2024.09_timing.c \
"

CARGT_OEI_00414_PATCHES = " \
    file://0001-oei-ddr-cargt-select-between-several-DDR-timing-conf.patch \
    file://0002-oei-ddr-cargt-read-the-DDR-configuration-ID-from-the.patch \
    file://0003-scripts-cargt-shared-table-generator-for-multi-DDR-b.patch \
    file://0004-boards-cargt00414-Cargt-i.MX-95-00414-OSM-L-SOM.patch \
"

SRC_URI:append = "${@(' ' + d.getVar('CARGT_OEI_00414_PATCHES') + ' ' + \
    ' '.join('file://' + e.split(':', 1)[1] for e in d.getVar('CARGT_OEI_00414_TIMINGS').split())) \
    if d.getVar('CARGT_OEI_00414') else ''}"

do_patch[prefuncs] += "${@'oei_create_cargt00414_board' if d.getVar('CARGT_OEI_00414') else ''}"

oei_create_cargt00414_board() {
    rm -rf ${S}/boards/cargt00414
    cp -a ${S}/boards/mx95lp5 ${S}/boards/cargt00414
    rm -f ${S}/boards/cargt00414/ddr/*.c
}

do_configure:prepend() {
    if [ -n "${CARGT_OEI_00414}" ]; then
        ddr=${S}/boards/cargt00414/ddr
        args=""
        for e in ${CARGT_OEI_00414_TIMINGS}; do
            name=${e%%:*}
            file=${e#*:}
            cp ${UNPACKDIR}/$file $ddr/
            args="$args $name=$ddr/$file"
        done
        rm -rf $ddr/gen
        python3 ${S}/scripts/cargt_ddr_merge.py $ddr/gen $args
    fi
}
