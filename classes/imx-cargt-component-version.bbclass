# Captures `git describe --tags` for a fetched component as a purely
# informational build reference, alongside -- not instead of -- its real
# PV/SRCPV package version. This mirrors the layer-level approach in
# imx-cargt-version.bbclass / <customer-layer>-version.bbclass: describe
# string is not safe to use for actual package version comparisons (it isn't
# guaranteed monotonic the way SRCPV's AUTOINC counter is), so it never
# touches PV -- it's only for humans, surfaced via sw-components.
#
# Deliberately NOT named/located anywhere near /etc/sw-versions: that file is
# swupdate's own compiled-in SWUPDATE_SW_VERSIONS_FILE (see swupdate.inc and
# board-version.bb), used for real install-if-different version gating.
#
# COMPONENT_GITVER is computed at PARSE time against the shared DL_DIR git
# mirror (not ${S}), and deliberately NOT via a do_install-time `git describe`
# against ${S}. Two reasons:
#   1. ${S} may not exist at all when do_install's signature is computed --
#      bitbake can satisfy do_install/do_package straight from a matching
#      sstate object (setscene) without ever running do_fetch/do_unpack,
#      especially on a fresh build tree sharing an existing sstate-cache/
#      downloads mirror. A `${S}`-based file-checksum or describe call would
#      silently keep serving a stale value in that case.
#   2. Computing it as a real BB variable makes it a normal vardep of
#      do_install (since the shell postfunc below references
#      ${COMPONENT_GITVER}), so a retroactive tag fix on an already-built
#      SRCREV correctly changes do_install's task signature and forces a
#      rebuild, instead of silently reusing an old sstate object forever.
# The DL_DIR mirror is always current at parse time as a side effect of
# SRCREV/AUTOREV resolution, which bitbake performs on every parse
# regardless of the build tree's local state -- so this works even for a
# brand-new checkout pointed at a long-lived shared DL_DIR/sstate-cache.
#
# Trade-off: this no longer reflects local working-tree modifications (e.g.
# an active `devtool modify` checkout, or applied recipe patches) the way
# `--dirty` against ${S} used to -- it always describes the raw upstream
# commit. Acceptable here since this string is meant to track what was
# *published*, not local WIP.

COMPONENT_GITVER_DIR ?= "${datadir}/component-gitver"

def cargt_get_component_gitver(d):
    import os
    import subprocess
    import bb.fetch2

    try:
        srcrev = bb.fetch2.get_srcrev(d)
    except bb.fetch2.FetchError:
        srcrev = None
    if not srcrev or srcrev == 'INVALID':
        return "unknown"
    # get_srcrev()'s default format is the sortable "AUTOINC+<hash>" string
    # (same as SRCPV) rather than a plain revision -- take the hash part.
    srcrev = srcrev.rsplit('+', 1)[-1]

    src_uri = (d.getVar('SRC_URI') or '').split()
    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
    except bb.fetch2.BBFetchException:
        return "unknown"

    for url in fetcher.urls:
        ud = fetcher.ud[url]
        if ud.type != 'git':
            continue
        clonedir = getattr(ud, 'clonedir', None)
        if not clonedir or not os.path.exists(clonedir):
            continue
        try:
            out = subprocess.check_output(
                ['git', 'describe', '--always', '--tags', srcrev],
                cwd=clonedir, stderr=subprocess.DEVNULL)
            return out.decode('utf-8').strip()
        except subprocess.CalledProcessError:
            continue

    return "unknown"

COMPONENT_GITVER = "${@cargt_get_component_gitver(d)}"

cargt_component_write_gitver() {
    install -d ${D}${COMPONENT_GITVER_DIR}
    echo "${COMPONENT_GITVER}" > ${D}${COMPONENT_GITVER_DIR}/${PN}
}

do_install[postfuncs] += "cargt_component_write_gitver"

FILES:${PN}:append = " ${COMPONENT_GITVER_DIR}/${PN}"
