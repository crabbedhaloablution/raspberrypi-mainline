# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mount-boot

DESCRIPTION="Raspberry Pi boot config files config.txt and cmdline.txt"

HOMEPAGE="
	https://www.raspberrypi.org/documentation/configuration/config-txt/README.md
	https://github.com/RPi-Distro/pi-gen
	"

GIT_COMMIT="652780757be196ac7292a9e1d3a8182a2b6c0de2"
SRC_URI="
	https://raw.githubusercontent.com/RPi-Distro/pi-gen/${GIT_COMMIT}/stage1/00-boot-files/files/config.txt -> config.txt-${P}
	https://raw.githubusercontent.com/RPi-Distro/pi-gen/${GIT_COMMIT}/stage1/00-boot-files/files/cmdline.txt -> cmdline.txt-${P}
	"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~arm ~arm64"

IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack() {
	for file in {config,cmdline}.txt; do
		cp "${DISTDIR}/${file}-${P}" "${S}/${file}" || die "Failed copying ${file}"
	done
}

src_install() {
	insinto /boot
	doins config.txt
	doins cmdline.txt
	echo 'CONFIG_PROTECT="/boot/cmdline.txt /boot/config.txt"' >  "10-${PN}"
	doenvd "10-${PN}"

}
