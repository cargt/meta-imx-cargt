def imx_cargt_get_layer_gitver(d):
    import subprocess
    layerdir = d.getVar('IMX_CARGT_LAYERDIR')
    try:
        # DEFAULT: standard `git describe` output.
        #   - exactly on a tag           -> "v1.0"
        #   - N commits past a tag       -> "v1.0-5-gabcdefg"
        #   - no tags reachable at all   -> bare short sha "abcdefg"
        #   - dirty working tree         -> "-dirty" suffix on any of the above
        # This is the widely-recognized git-describe convention and is safe
        # to use as a purely informational string (e.g. os-release
        # BUILD_ID_IMX_CARGT) as long as nothing does real semver-style
        # version-gating against it.
        return subprocess.check_output(
            ['git', '-C', layerdir, 'describe', '--always', '--dirty', '--tags'],
            stderr=subprocess.DEVNULL
        ).decode().strip()

        # ALTERNATIVE: exact-tag-only mode.
        # --exact-match fails (raises, caught below -> 'unknown') on any
        # commit that isn't tagged exactly, forcing every reported build to
        # be a clean tagged release. Uncomment this block and comment out
        # the block above to switch. Note: a dirty working tree will also
        # report 'unknown' in this mode, not a dirty-suffixed tag.
        #
        # return subprocess.check_output(
        #     ['git', '-C', layerdir, 'describe', '--tags', '--exact-match'],
        #     stderr=subprocess.DEVNULL
        # ).decode().strip()
    except Exception:
        return 'unknown'

IMX_CARGT_GITVER := "${@imx_cargt_get_layer_gitver(d)}"
# NOTE '?=' will set this if no layer has overridden this, such as a customer layer
SW_VER_STRING ?= "${IMX_CARGT_GITVER}"