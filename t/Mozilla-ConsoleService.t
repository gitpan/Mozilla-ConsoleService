use strict;
use warnings FATAL => 'all';

use Test::More tests => 7;
use Mozilla::Mechanize;
use URI::file;

BEGIN { use_ok('Mozilla::ConsoleService') };

my $url = URI::file->new_abs("t/test.html")->as_string;
my $moz = Mozilla::Mechanize->new(quiet => 1, visible => 0);

my @_last_call = 'NONE';
is(Mozilla::ConsoleService::Register(sub { @_last_call = @_; }), 1);

ok($moz->get($url));
is($moz->title, "Test-forms Page");
like($_last_call[0], qr/missing } after function body/);
like($_last_call[0], qr/test\.html/);
like($_last_call[0], qr/line/);

$moz->close();
