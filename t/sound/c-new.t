use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download::Sound;
use Test::More tests => 1;

my $class = "WWW::NicoSound::Download::Sound";
my $sound = $class->new;

isa_ok( $sound, $class );

