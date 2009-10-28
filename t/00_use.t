use strict;
use warnings;

use Test::More tests => 7;

BEGIN {
    use_ok( "WWW::NicoSound::Download" );

    my @methods = qw(
        get_id  get_raw  save_mp3  get_ids  can_find_homepage
    );

    foreach my $method ( @methods ) {
        use_ok( "WWW::NicoSound::Download", $method );
    }

    use_ok( "WWW::NicoSound::Download", @methods );
};


