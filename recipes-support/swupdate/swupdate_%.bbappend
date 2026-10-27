FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://cargt-swupdate-mods.cfg \
            file://cargt-swupdate.css \
            file://cargt-theme.js \
            file://cargt-logo-reversed.svg \
            file://cargt-favicon.png \
            file://Manrope-Variable.woff2 \
            file://Manrope-OFL.txt \
            "

FILESEXTRAPATHS:prepend := "${THISDIR}/swupdate:"
SRC_URI += " file://swupdate.cfg \
            "

SW_VER_STRING ?= "undefined"

# The web UI ships the Manrope font (SIL OFL 1.1)
LICENSE:append = " & OFL-1.1"
LICENSE:${PN}-www = "MIT & OFL-1.1"

# Apply one sed expression to the web UI's index.html and fail the build if
# the expected result is missing, so an SWUpdate update that changes the
# upstream markup can't silently drop the Cargt branding.
cargt_www_edit() {
    sed -i -e "$1" ${D}${wwwdir}/index.html
    grep -qF -- "$2" ${D}${wwwdir}/index.html || \
        bbfatal "swupdate web UI: index.html edit did not apply (expected: $2)"
}

do_install:append() {
    mkdir -p ${D}/etc
    cp -f ${UNPACKDIR}/swupdate.cfg ${D}/etc/swupdate.cfg

    # Cargt branding for the web UI (Brand Guidelines RD03): colours, Manrope,
    # reversed logo, dark theme by default with a light/dark toggle.
    install -d ${D}${wwwdir}/fonts
    install -m 0644 ${UNPACKDIR}/cargt-swupdate.css ${D}${wwwdir}/css/
    install -m 0644 ${UNPACKDIR}/cargt-theme.js ${D}${wwwdir}/js/
    install -m 0644 ${UNPACKDIR}/cargt-logo-reversed.svg ${D}${wwwdir}/images/cargt-logo.svg
    install -m 0644 ${UNPACKDIR}/cargt-favicon.png ${D}${wwwdir}/images/favicon.png
    install -m 0644 ${UNPACKDIR}/Manrope-Variable.woff2 ${UNPACKDIR}/Manrope-OFL.txt ${D}${wwwdir}/fonts/
    # cargt-swupdate.css replaces the page background
    rm -f ${D}${wwwdir}/images/background.jpg

    # Theme script before the stylesheets so the page never flashes light
    cargt_www_edit 's|<link rel="stylesheet" href="css/bootstrap.min.css">|<script src="js/cargt-theme.js"></script>&|' \
        'js/cargt-theme.js'
    cargt_www_edit 's|<link rel="stylesheet" href="css/swupdate.min.css">|&<link rel="stylesheet" href="css/cargt-swupdate.css">|' \
        'css/cargt-swupdate.css'
    cargt_www_edit 's|<title>[^<]*</title>|<title>Cargt Software Update</title>|' \
        '<title>Cargt Software Update</title>'
    cargt_www_edit 's|src="images/logo.png" alt=""|src="images/cargt-logo.svg" alt="Cargt"|' \
        'images/cargt-logo.svg'
    # Solid cards; keep the navbar items visible on phones
    cargt_www_edit 's| opacity-75||g' \
        'class="card"'
    cargt_www_edit 's|navbar-expand-sm|navbar-expand|' \
        'navbar-expand navbar-dark'
    cargt_www_edit 's|<li class="nav-item"><a id="swu-restart"|<li class="nav-item"><button id="cargt-theme-toggle" class="btn nav-link" type="button" title="Switch between light and dark" aria-label="Switch between light and dark theme"><i class="fas fa-sun"></i><i class="fas fa-moon"></i></button></li>&|' \
        'id="cargt-theme-toggle"'
    cargt_www_edit 's|<h1 class="display-4"><span class="text-primary">SW</span>Update</h1><p class="lead">Software update for embedded systems</p><p>Upload a software image below, or restart the system at the top right corner.</p>|<h1 class="display-6">Software Update</h1><p class="lead mb-1">Install a new software image on this device.</p><p class="mb-2">Upload a .swu file below. Keep the device powered until the update finishes.</p>|' \
        '<h1 class="display-6">Software Update</h1>'
    cargt_www_edit 's|<h5><i class="fas fa-wrench"></i> Software Update</h5>|<h5>Install an update</h5>|' \
        '<h5>Install an update</h5>'
    cargt_www_edit 's|<span class="dz-message">Click here, or drag and drop a software update image file to this area.</span>|<span class="dz-message"><i class="fas fa-upload fa-2x d-block mb-2"></i>Drop a .swu file here, or click to choose one.<small>The update starts as soon as you drop the file.</small></span>|' \
        'fa-upload'
    cargt_www_edit 's|progress-bar progress-bar-striped"|progress-bar progress-bar-striped progress-bar-animated"|' \
        'progress-bar-animated'
    cargt_www_edit 's|<i class="fas"></i> Messages</a>|<i class="fas"></i> Update log</a>|' \
        'Update log</a>'
    cargt_www_edit 's|</body>|<footer class="cargt-footer container">Cargt · Modern electronics. Confidence at every step.</footer>&|' \
        'class="cargt-footer'
}

RDEPENDS:${PN} += "lua tar zstd"
DEPENDS += "kern-tools-native systemd"


