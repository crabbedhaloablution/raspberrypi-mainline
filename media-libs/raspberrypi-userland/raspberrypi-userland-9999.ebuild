# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake-utils flag-o-matic udev

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN/-//}.git"
	SRC_URI=""
else
	#We base our versioning off Raspbian's
	#Go to https://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-userland/
	#Example:
	#libraspberrypi-bin-dbgsym_2+git20201022~151804+e432bc3-1_arm64.deb
	#"e432bc3" is the git commit to plug in below.
	GIT_COMMIT="e432bc3"
	SRC_URI="https://github.com/raspberrypi/userland/tarball/${GIT_COMMIT} -> ${P}.tar.gz"
	KEYWORDS="~arm64 ~arm"
	S="${WORKDIR}/raspberrypi-userland-${GIT_COMMIT}"
fi


DESCRIPTION="Raspberry Pi userspace tools and libraries"
HOMEPAGE="https://github.com/raspberrypi/userland"

LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="acct-group/video
	!media-libs/raspberrypi-userland-bin"

#Install in $(get_libdir)
#See https://github.com/raspberrypi/userland/pull/650
PATCHES=( "${FILESDIR}/${PN}-libdir.patch" )
#Don't install includes that collide.
PATCHES+=( "${FILESDIR}/${PN}-include.patch" )

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
	sed -i \
		-e 's:add_library(fdt:add_library(fdt STATIC:' \
		"${S}/opensrc/helpers/libfdt/CMakeLists.txt" || die
}

src_install() {
	cmake-utils_src_install
	udev_dorules "${FILESDIR}/92-local-vchiq-permissions.rules"
}
