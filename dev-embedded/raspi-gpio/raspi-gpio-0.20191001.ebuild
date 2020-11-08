# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Tool to help debug / hack at the BCM283x GPIO"

HOMEPAGE="https://github.com/RPi-Distro/raspi-gpio/"

SRC_URI="https://archive.raspberrypi.org/debian/pool/main/r/${PN}/${PN}_${PV}.tar.xz"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~arm arm64"

IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}"
