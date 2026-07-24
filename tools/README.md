# tools/

## check-unused-patches.sh

Scans every `recipes-*/` directory for `*.patch`/`*.diff` files that aren't
referenced (`file://<name>`) by any `.bb`/`.bbappend`/`.inc` in this layer,
and exits non-zero if it finds any.

```
tools/check-unused-patches.sh
```

Run it before committing changes to a recipe's patch directory, especially
after exporting patches from a `devtool modify` workspace.

## Exporting patches from a devtool workspace without leaving orphans

`recipes-bsp/u-boot/u-boot-imx/` has twice accumulated dozens of unused
patch files (cleaned up in commits `821c55c`, `33c1ec2`, and `6d672c5`) from
the same mistake: running `git format-patch` for a whole branch straight
into the tracked recipe directory, then committing the directory instead of
just the file(s) actually added to `SRC_URI`. If the workspace branch is
later rebased or squashed, the original export is never revisited and the
stale files just sit there.

To avoid it:

1. Export to a scratch directory, not the recipe directory:
   ```
   git format-patch -o /tmp/patches <last-exported-commit>..HEAD
   ```
2. Copy only the new/changed file(s) you're actually wiring into `SRC_URI`
   into the recipe's patch directory.
3. `git add` those specific files (not the whole directory), and review
   `git status` before committing.
4. Run `tools/check-unused-patches.sh` before committing.
