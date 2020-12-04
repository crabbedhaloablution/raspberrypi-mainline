# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Firmware for Bluetooth on Raspberry 3 and 4"
HOMEPAGE="https://github.com/RPi-Distro/bluez-firmware
	https://archive.raspberrypi.org/debian/pool/main/b/bluez-firmware/"
SRC_URI="https://archive.raspberrypi.org/debian/pool/main/b/bluez-firmware/bluez-firmware_$(ver_cut 1-2)-$(ver_cut 3)+rpt$(ver_cut 5).debian.tar.xz"
S="${WORKDIR}"
LICENSE="Broadcom"
SLOT="0"
KEYWORDS="~arm ~arm64"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""
DOCS="debian/changelog"

src_install() {
	default
	insinto /lib/firmware/brcm
	doins broadcom/*
}
