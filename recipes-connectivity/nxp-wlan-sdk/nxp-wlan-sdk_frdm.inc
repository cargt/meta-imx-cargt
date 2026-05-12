FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Conditional WiFi patches: include only if meta-imx-frdm layer is not present
# If meta-imx-frdm is in BBLAYERS, its patches will override these (higher priority)
# If meta-imx-frdm is not available, these provide fallback support
SRC_URI += " \
	${@'file://0001-mxm_wifiex-update-to-mxm6x18505.p14-release.patch' if 'meta-imx-frdm' not in '${BBLAYERS}' else ''} \
	${@'file://0002-Makefile-remove-script-related-setting-to-avoid-buil.patch' if 'meta-imx-frdm' not in '${BBLAYERS}' else ''} \
"
