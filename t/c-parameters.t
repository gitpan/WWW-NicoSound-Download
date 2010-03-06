use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download ( );

use Test::More tests => 2;

is( $WWW::NicoSound::Download::VERSION, "1.07" );
is( $WWW::NicoSound::Download::IS_RIOT, "0"    );

