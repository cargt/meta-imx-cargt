#!/bin/bash
#
# Find *.patch/*.diff files in this layer's recipe directories that are not
# referenced (via file://<name>) by any .bb/.bbappend/.inc in the layer.
#
# These are orphaned patches: usually leftovers from a `git format-patch`
# export that got committed wholesale instead of just the file(s) actually
# wired into SRC_URI. See recipes-bsp/u-boot/u-boot-imx/ history for the
# incident that prompted this check.
#
# Usage: tools/check-unused-patches.sh
# Exit status: 0 if no orphans found, 1 if any orphans are found.
#
# MIT License
# Copyright 2026 Cargt

set -u

layer_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$layer_root" || exit 1

unused=()

while IFS= read -r patch_path; do
    name="$(basename "$patch_path")"
    if ! grep -rlF --include='*.bb' --include='*.bbappend' --include='*.inc' \
            "file://${name}" . >/dev/null 2>&1; then
        unused+=("$patch_path")
    fi
done < <(find recipes-* -type f \( -name '*.patch' -o -name '*.diff' \) | sort)

if [ "${#unused[@]}" -gt 0 ]; then
    printf 'UNUSED: %s\n' "${unused[@]}"
    echo
    echo "${#unused[@]} unused patch file(s) found. Remove them or wire them into SRC_URI."
    exit 1
fi

echo "No unused patch files found."
exit 0
