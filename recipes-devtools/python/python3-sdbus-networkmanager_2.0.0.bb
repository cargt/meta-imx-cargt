SUMMARY = "Python bindings for NetworkManager using python-sdbus"
DESCRIPTION = "Python-sdbus-networkmanager provides Python bindings to interact with NetworkManager via D-Bus, built on top of python-sdbus."
HOMEPAGE = "https://github.com/python-sdbus/python-sdbus-networkmanager"
LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

inherit pypi setuptools3

SRC_URI[sha256sum] = "3572ac3a8189c683ec0416acb148761773a8f0881ad3d78b6d6f6864eff9c50b"

# Specify the PyPI project name for python-sdbus-networkmanager
PYPI_PACKAGE = "sdbus-networkmanager"

# Dependencies
DEPENDS += "python3-sdbus"

# Additional dependencies if needed, for example, for NetworkManager itself
RDEPENDS:${PN} += "networkmanager python3-sdbus"
