use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More tests => 2;

BEGIN {
    use_ok( "WWW::NicoSound::Download" );

    my @methods = qw(
        get_id  get_raw  save_mp3  get_ids
    );
    use_ok( "WWW::NicoSound::Download", @methods );
};


