# Mount the data partition (LABEL=data, the last partition in
# cargt-dev.wks.in) on /data. Every machine gets it: with nofail, a board
# without a data partition boots as before.
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
