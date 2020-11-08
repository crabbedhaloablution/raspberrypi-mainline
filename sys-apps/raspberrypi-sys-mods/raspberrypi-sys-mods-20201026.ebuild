# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit udev systemd

DESCRIPTION="System tweaks for the Raspberry Pi"

HOMEPAGE="https://github.com/RPi-Distro/raspberrypi-sys-mods"

SRC_URI="https://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-sys-mods/${PN}_${PV}.tar.xz"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~arm ~arm64"

IUSE="+ssh"

RDEPEND="
	acct-group/input
	acct-group/i2c
	acct-group/spi
	acct-group/gpio
	acct-group/video
	ssh? ( net-misc/openssh )
	"

DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}"

DOCS=( debian/changelog )

src_prepare() {
	default
	sed -i \
		-e 's:usr/lib/raspberrypi-sys-mods:usr/libexec/raspberrypi-sys-mods:' \
		lib/udev/rules.d/15-i2c-modprobe.rules || die "Failed sedding 15-i2c-modprobe.rules"
}

src_install() {
	default
	insinto /etc/sysctl.d/
	doins etc.armhf/sysctl.d/98-rpi.conf

	insinto /etc/modprobe.d/
	#See https://github.com/RPi-Distro/raspberrypi-sys-mods/issues/37
	doins etc.armhf/modprobe.d/blacklist-8192cu.conf
	#See https://github.com/raspberrypi/linux/issues/2164#issuecomment-322152871
	doins etc.armhf/modprobe.d/blacklist-rtl8xxxu.conf

	udev_dorules etc.armhf/udev/rules.d/99-com.rules
	udev_dorules lib/udev/rules.d/{15-i2c-modprobe.rules,70-microbit.rules}
	exeinto /usr/libexec/raspberrypi-sys-mods
	doexe usr/lib/raspberrypi-sys-mods/i2cprobe

	systemd_newunit debian/raspberrypi-sys-mods.rpi-display-backlight.service rpi-display-backlight.service
	for target in reboot.target halt.target poweroff.target; do
		systemd_enable_service "${target}" rpi-display-backlight.service
	done
	if use ssh; then
		systemd_newunit	debian/raspberrypi-sys-mods.sshswitch.service sshswitch.service
		systemd_enable_service multi-user.target sshswitch.service

		systemd_newunit	debian/raspberrypi-sys-mods.regenerate_ssh_host_keys.service regenerate_ssh_host_keys.service
		systemd_enable_service multi-user.target regenerate_ssh_host_keys.service
	fi
}
