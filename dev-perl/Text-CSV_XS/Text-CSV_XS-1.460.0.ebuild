# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=HMBRAND
DIST_A_EXT=tgz
DIST_VERSION=1.46
DIST_EXAMPLES=("examples/*")
inherit perl-module

DESCRIPTION="Comma-separated values manipulation routines"

SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND="
	virtual/perl-IO
	virtual/perl-XSLoader
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		virtual/perl-Test-Simple
	)
"

PERL_RM_FILES=("t/00_pod.t" "t/01_pod.t")
