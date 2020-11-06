# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils flag-o-matic udev

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN/-//}.git"
	SRC_URI=""
else
	GIT_COMMIT="dff5760"
	SRC_URI="https://github.com/raspberrypi/userland/tarball/${GIT_COMMIT} -> ${P}.tar.gz"
	KEYWORDS="~arm64 ~arm"
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
RDEPEND="acct-group/video
	!media-libs/raspberrypi-userland-bin"

#raspberrypi-userland.patch:
#See https://github.com/raspberrypi/userland/pull/650
PATCHES=( "${FILESDIR}/${PN}-libdir.patch"
	"${FILESDIR}/${PN}-include.patch" )

pkg_setup() {
	append-ldflags $(no-as-needed)
	mycmakeargs=(
		-DVMCS_INSTALL_PREFIX="/usr"
		-DARM64=$(usex arm64 ON OFF)
	)
}

src_prepare() {
	cmake-utils_src_prepare
	sed -i \
		-e 's:DESTINATION ${VMCS_INSTALL_PREFIX}/src:DESTINATION ${VMCS_INSTALL_PREFIX}/'"share/doc/${PF}:" \
		"${S}/makefiles/cmake/vmcs.cmake" || die "Failed sedding makefiles/cmake/vmcs.cmake"
}

src_install() {
	cmake-utils_src_install
	udev_dorules "${FILESDIR}/92-local-vchiq-permissions.rules"
}