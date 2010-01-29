use utf8;
use strict;
use warnings;
use File::Spec::Functions qw( catfile );
use WWW::NicoSound::Download ( );

use Test::More tests => 5;

# Install target method.
{
    no strict "refs";
    *t_func = \&WWW::NicoSound::Download::_validate_filename;
}

is( t_func( "a" ),  "a.mp3" );
is( t_func( "あ" ), "あ.mp3" );

is( t_func( "a.mp3" ), "a.mp3" );

my @pathes = qw( t data );
is( t_func( catfile( @pathes ) ), ( join "_", @pathes ) . ".mp3" );

@pathes = qw( あ か );
is( t_func( catfile( @pathes ) ), ( join "_", @pathes ) . ".mp3" );

