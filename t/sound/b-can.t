use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download::Sound;
use Test::More tests => 1;

my $module  = "WWW::NicoSound::Download::Sound";
my @methods = qw(
    new
    is_id_valid
    info_url
    sound_url
    parse_id_from_url
    parse_filename_from_title
);

can_ok( $module, @methods );

