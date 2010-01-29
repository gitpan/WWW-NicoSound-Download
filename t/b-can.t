use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download ( );

use Test::More tests => 1;

my $module  = "WWW::NicoSound::Download";
my @methods = qw(
    can_find_homepage
    _is_id_valid  get_id  get_ids
    _get_cookies_and_title
    get_raw  save_mp3  
    _validate_filename
);

can_ok( $module, @methods );

