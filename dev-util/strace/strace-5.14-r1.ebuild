# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/strace/strace.git"
	inherit git-r3
else
	SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.xz"
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc ~x86 ~amd64-linux ~x86-linux"
fi

DESCRIPTION="A useful diagnostic, instructional, and debugging tool"
HOMEPAGE="https://strace.io/"

LICENSE="BSD"
SLOT="0"
IUSE="aio perl selinux static unwind elfutils"

REQUIRED_USE="?? ( unwind elfutils )"

BDEPEND="
	virtual/pkgconfig
"
LIB_DEPEND="
	unwind? ( sys-libs/libunwind[static-libs(+)] )
	elfutils? ( dev-libs/elfutils[static-libs(+)] )
	selinux? ( sys-libs/libselinux[static-libs(+)] )
"
# strace only uses the header from libaio to decode structs
DEPEND="
	static? ( ${LIB_DEPEND} )
	aio? ( >=dev-libs/libaio-0.3.106 )
	sys-kernel/linux-headers
"
RDEPEND="
	!static? ( ${LIB_DEPEND//\[static-libs(+)]} )
	perl? ( dev-lang/perl )
"

PATCHES=(
	"${FILESDIR}/${PN}-5.11-static.patch"
)

src_prepare() {
	default

	eautoreconf

	if [[ ! -e configure ]] ; then
		# git generation
		sed /autoreconf/d -i bootstrap || die
		./bootstrap || die
		eautoreconf
		[[ ! -e CREDITS ]] && cp CREDITS{.in,}
	fi

	filter-lfs-flags # configure handles this sanely

	export ac_cv_header_libaio_h=$(usex aio)
	use elibc_musl && export ac_cv_header_stdc=no

	# Stub out the -k test since it's known to be flaky. #545812
	sed -i '1iexit 77' tests*/strace-k.test || die
}

src_configure() {
	# Set up the default build settings, and then use the names strace expects.
	tc-export_build_env BUILD_{CC,CPP}
	local v bv
	for v in CC CPP {C,CPP,LD}FLAGS ; do
		bv="BUILD_${v}"
		export "${v}_FOR_BUILD=${!bv}"
	done

	# Don't require mpers support on non-multilib systems. #649560
	local myeconfargs=(
		--disable-gcc-Werror
		--enable-mpers=check
		$(use_enable static)
		$(use_with unwind libunwind)
		$(use_with elfutils libdw)
		$(use_with selinux libselinux)
	)
	econf "${myeconfargs[@]}"
}

src_test() {
	if has usersandbox ${FEATURES} ; then
		ewarn "Test suite is known to fail with FEATURES=usersandbox -- skipping ..." #643044
		return 0
	fi

	default
}

src_install() {
	default
	if use perl ; then
		exeinto /usr/bin
		doexe src/strace-graph
	fi
	dodoc CREDITS
}
