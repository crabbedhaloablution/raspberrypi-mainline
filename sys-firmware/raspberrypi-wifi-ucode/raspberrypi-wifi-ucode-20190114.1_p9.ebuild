# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Most up-to-date uCode for the Broadcom wifi chips on Raspberry Pi SBCs"
HOMEPAGE="https://github.com/RPi-Distro/firmware-nonfree
	https://archive.raspberrypi.org/debian/pool/main/f/firmware-nonfree"
MY_PN=firmware-nonfree
SRC_URI="https://archive.raspberrypi.org/debian/pool/main/f/${MY_PN}/${MY_PN}_$(ver_cut 1)-$(ver_cut 2)+rpt$(ver_cut 4).debian.tar.xz"

LICENSE="Broadcom"
SLOT="0"
KEYWORDS="~arm ~arm64"

RDEPEND="!sys-kernel/linux-firmware[-savedconfig]"
DEPEND=""

S="${WORKDIR}"

src_prepare() {
	default
	eapply -p1 debian/patches/sdio-txt-files.patch
}

src_install() {
	insinto /lib/firmware/brcm
	doins brcm/*
	dodoc debian/changelog
}
