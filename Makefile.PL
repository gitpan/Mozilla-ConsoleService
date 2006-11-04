use warnings FATAL => 'all';
use strict;

use 5.008007;
use Config;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Mozilla::ConsoleService',
    VERSION_FROM      => 'lib/Mozilla/ConsoleService.pm', # finds $VERSION
    PREREQ_PM         => { 'Mozilla::Mechanize' => 0.05 },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Mozilla/ConsoleService.pm', # retrieve abstract from module
       AUTHOR         => 'Boris Sukholitko <boris@>') : ()),
    LIBS              => ['-L/usr/lib/mozilla -lxpcom -lplds4 -lplc4 -lnspr4 -ldl -lc -lpthread'], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    CC            => 'g++',
    INC               => '-I. -I/usr/include/mozilla -I/usr/include/mozilla/nspr -I/usr/include/mozilla/xpcom',
    LD            => "LD_RUN_PATH=/usr/lib/mozilla $Config{ld}",
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);