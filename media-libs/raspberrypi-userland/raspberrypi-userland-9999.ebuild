# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils flag-o-matic

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN/-//}.git"
	SRC_URI=""
else
	GIT_COMMIT="dff5760"
	SRC_URI="https://github.com/raspberrypi/userland/tarball/${GIT_COMMIT} -> ${P}.tar.gz"
	KEYWORDS="arm"
	S="${WORKDIR}/raspberrypi-userland-${GIT_COMMIT}"
fi


DESCRIPTION="Raspberry Pi userspace tools and libraries"
HOMEPAGE="https://github.com/raspberrypi/userland"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND=""

#EGIT_REPO_URI="https://github.com/raspberrypi/userland"

pkg_setup() {
	append-ldflags $(no-as-needed)
}

src_configure() {
	local mycmakeargs=(
		-DVMCS_INSTALL_PREFIX="/usr"
		-DARM64=$(usex arm64 1 0)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	insinto /lib/udev/rules.d
	doins "${FILESDIR}"/92-local-vchiq-permissions.rules

	dodir /usr/share/doc/${PF}
	mv "${D}"/usr/src/hello_pi "${D}"/usr/share/doc/${PF}/
	rmdir "${D}"/usr/src
}
