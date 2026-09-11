# NOTE: '?=' will only take effect if no other layer has already set
# BUILD_ID, e.g. a customer layer that doesn't implement its own version
# tracking. A layer that wants to guarantee it owns BUILD_ID should use
# a plain '=' assignment instead, which always wins regardless of parse
# order (mirrors the same fallback pattern used for SW_VER_STRING in
# imx-cargt-version.bbclass).
BUILD_ID ?= "${IMX_CARGT_GITVER}"

BUILD_ID_IMX_CARGT = "${IMX_CARGT_GITVER}"
OS_RELEASE_FIELDS += "BUILD_ID_IMX_CARGT"

do_compile[vardeps] += "BUILD_ID IMX_CARGT_GITVER"