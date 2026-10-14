# Cargt i.MX 95 00414 OSM-L SOM System Manager support.
#
# The 00414 uses the EVK PMIC set (PF09 + PF5301 + PF5302 on LPI2C1), so
# its board port (boards/cargt00414) is a copy of boards/mcimx95evk taken
# from the fetched source at build time, plus a small patch making the
# EVK-only PCAL6408A bus expander and PCA2131 RTC optional, and one adding
# the SOM EEPROM board control (BRD_SM_CTRL_EEPROM). Copying at
# build time keeps the port in step with SRCREV bumps; only the Cargt
# delta lives in this layer.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

CARGT_SM_00414 = "${@'1' if d.getVar('SYSTEM_MANAGER_CONFIG') == 'mx95cargt00414' else ''}"

SRC_URI:append = "${@' \
    file://0001-boards-cargt00414-make-EVK-bus-expander-and-RTC-optional.patch \
    file://0002-boards-cargt00414-add-SOM-EEPROM-board-control.patch \
    file://mx95cargt00414.cfg \
    ' if d.getVar('CARGT_SM_00414') else ''}"

do_patch[prefuncs] += "${@'sm_create_cargt00414_board' if d.getVar('CARGT_SM_00414') else ''}"

sm_create_cargt00414_board() {
    rm -rf ${S}/boards/cargt00414
    cp -a ${S}/boards/mcimx95evk ${S}/boards/cargt00414
}

do_configure:prepend() {
    if [ -f "${UNPACKDIR}/mx95cargt00414.cfg" ]; then
        cp ${UNPACKDIR}/mx95cargt00414.cfg ${S}/configs/
    fi
}
