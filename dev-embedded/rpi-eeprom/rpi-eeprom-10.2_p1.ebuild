# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8,9} )

inherit python-r1 systemd

DESCRIPTION="Raspberry Pi 4 bootloader and the VL805 USB controller updater"
HOMEPAGE="https://github.com/raspberrypi/rpi-eeprom/"
MY_P="${PN}-$(ver_cut 1-2)"
MY_BASE_URL="https://archive.raspberrypi.org/debian/pool/main/r/${PN}/${PN}_$(ver_cut 1-2)"
SRC_URI="${MY_BASE_URL}-$(ver_cut 4).debian.tar.xz
	${MY_BASE_URL}.orig.tar.gz"
SLOT="0"
LICENSE="BSD rpi-eeprom"
KEYWORDS="~arm ~arm64"
IUSE=""

DEPEND="sys-apps/help2man
	${PYTHON_DEPS}"
RDEPEND="sys-apps/flashrom
	${PYTHON_DEPS}
	>=media-libs/raspberrypi-userland-0_pre20201022"

S="${WORKDIR}"

src_prepare() {
	default
	sed -i \
		-e 's:/etc/default/rpi-eeprom-update:/etc/conf.d/rpi-eeprom-update:' \
		"${MY_P}/rpi-eeprom-update" || die "Failed sed on rpi-eeprom-update"
}

src_install() {
	pushd "${MY_P}" 1>/dev/null || die "Cannot change into directory ${P}"

	python_scriptinto /usr/sbin
	python_foreach_impl python_newscript rpi-eeprom-config rpi-eeprom-config

	dosbin rpi-eeprom-update
	keepdir /var/lib/raspberrypi/bootloader/backup

	for dir in critical stable beta; do
		insinto /lib/firmware/
		doins -r firmware/${dir}
	done

	dodoc firmware/release-notes.md

	help2man -N \
		--version-string="${PV}" --help-option="-h" \
		--name="Bootloader EEPROM configuration tool for the Raspberry Pi 4B" \
		--output=rpi-eeprom-config.1 ./rpi-eeprom-config || die "Failed to create manpage for rpi-eeprom-config"

	help2man -N \
		--version-string="${PV}" --help-option="-h" \
		--name="Checks whether the Raspberry Pi bootloader EEPROM is \
			up-to-date and updates the EEPROM" \
		 --output=rpi-eeprom-update.1 ./rpi-eeprom-update || die "Failed to create manpage for rpi-eeprom-update"

	doman rpi-eeprom-update.1 rpi-eeprom-config.1

	newconfd rpi-eeprom-update-default rpi-eeprom-update

	popd 1>/dev/null

	pushd debian 1>/dev/null || die "Cannot change into directory debian"

	systemd_newunit rpi-eeprom.rpi-eeprom-update.service rpi-eeprom-update.service
	newdoc changelog changelog.Debian

	popd 1>/dev/null

	keepdir /var/lib/raspberrypi/bootloader/backup

	newinitd "${FILESDIR}/init.d_rpi-eeprom-update-1" "rpi-eeprom-update"
}

pkg_postinst() {
	:
}
