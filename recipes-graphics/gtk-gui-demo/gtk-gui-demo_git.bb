# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

# Unable to find any files that looked like license statements. Check the accompanying
# documentation and source headers and set LICENSE and LIC_FILES_CHKSUM accordingly.
#
# NOTE: LICENSE is being set to "CLOSED" to allow you to at least start building - if
# this is not accurate with respect to the licensing of the software being built (it
# will not be in most cases) you must specify the correct value before using this
# recipe for anything other than initial testing/development!
SUMMARY = "GTK4 GUI Demo Application"
DESCRIPTION = "Python GTK4 application for embedded display"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

SRC_URI = "git://git@gitlab.com/cargt-internal/gui/gtk-gui.git;protocol=ssh;branch=main"

# Modify these as desired
PV = "1.0+git"
# SRCREV = "c5e52542f189c69863d98e83e9ad0212d45524ad"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS += "ttf-ubuntu-font-family"

#RDEPENDS:${PN} += " \
#    python3-pygobject \
#    python3-core \
#"
# Need to upgrade project to gtk4
RDEPENDS:${PN} += " \
    python3-pygobject \
    python3-core \
    gdk-pixbuf \
    librsvg-gtk \
    gtk4 \
"

# NOTE: no Makefile found, unable to determine what needs to be done

do_configure () {
	# Specify any needed configure commands here
	:
}

do_compile () {
	# Specify compilation commands here
	:
}

do_install () {
    install -d ${D}${libdir}/gtk-gui-demo
    install -d ${D}${bindir}
    
    # Install all Python files from root directory
    install -m 0644 ${S}/*.py ${D}${libdir}/gtk-gui-demo/
    
    # Copy subdirectories
    cp -r ${S}/screens ${D}${libdir}/gtk-gui-demo/
    cp -r ${S}/utils ${D}${libdir}/gtk-gui-demo/
    cp -r ${S}/assets ${D}${libdir}/gtk-gui-demo/
    
    # Create wrapper script in /usr/bin
    cat > ${D}${bindir}/gtk-gui-demo << 'EOF'
#!/bin/sh
export GSK_RENDERER=cairo
cd /usr/lib/gtk-gui-demo
exec python3 main.py "$@"
EOF
    chmod 0755 ${D}${bindir}/gtk-gui-demo
}

FILES:${PN} = " \
    ${libdir}/gtk-gui-demo/* \
    ${bindir}/gtk-gui-demo \
"
