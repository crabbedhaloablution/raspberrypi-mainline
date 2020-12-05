# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit udev systemd

DESCRIPTION="This is a sample skeleton ebuild file"
HOMEPAGE="https://github.com/RPi-Distro/pi-bluetooth
	https://archive.raspberrypi.org/debian/pool/main/p/pi-bluetooth/"
SRC_URI="https://archive.raspberrypi.org/debian/pool/main/p/${PN}/${PN}_${PV}.tar.xz"
S="${WORKDIR}/${PN}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm ~arm64"
IUSE="systemd"
RDEPEND="sys-firmware/raspberrypi-bluetooth-ucode
	net-wireless/bluez[deprecated]
	"
DEPEND=""
BDEPEND=""
DOCS="debian/changelog"
PATCHES=(
	"${FILESDIR}"/${P}-001-change-service-unit-type-to-oneshot.patch
	"${FILESDIR}"/${P}-002-Integrated-UART-bluetooth-adapter-not-working-after-restart-if-another.patch
	)

src_prepare() {
	default
	ebegin "Sed'ing path for hciconfig in bthelper"
	if grep -q -E "(^| )/bin/hciconfig" usr/bin/bthelper; then
		sed -i -E \
			-e 's:(^| )/bin/hciconfig:\1/usr/bin/hciconfig:' \
			usr/bin/bthelper || die "Sed of bthelper for hciconfig path failed"
		eend
	else
		eend 1
		eerror "usr/bin/bthelper no longer needs its path for /bin/hciconfig corrected"
		die "Please remove workaround sed from ${PF} ebuild"
	fi
	if ! use systemd; then
		# bluetoothctl needs the bluez daemon running to work.
		# udev may run before, so we remove the bluetoothctl power-cycle
		# since it's not essential
		ebegin "Sed'ing to remove bluetoothctl from bthelper on non-systemd systems."
		if grep -q '# Force reinitialisation to allow extra features such as Secure Simple Pairing' usr/bin/bthelper; then
			sed -i \
				-e '/# Force reinitialisation to allow extra features such as Secure Simple Pairing/,+3d' \
				usr/bin/bthelper || die "Failed sed'ing to remove bluetoothctl"
			eend
		else
			eend 1
			eerror "usr/bin/bthelper no longer contains grep patter # Force reinitialisation(...)"
			die "Check what's wrong in ${PF} ebuild"
		fi
	fi
}

src_install() {
	default
	dobin usr/bin/btuart
	dobin usr/bin/bthelper
	if use systemd; then
		udev_dorules lib/udev/rules.d/90-pi-bluetooth.rules
		for service in {bthelper@,hciuart}.service; do
			systemd_newunit debian/${PN}.${service} ${service}
		done
	else
		newinitd "${FILESDIR}"/init.d_rpi-hciuart-1 hciuart
		udev_dorules "${FILESDIR}"/95-pi-bthelper.rules
	fi
}
