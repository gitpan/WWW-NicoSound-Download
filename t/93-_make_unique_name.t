use strict;
use warnings;
use WWW::NicoSound::Download ( );

use Test::More tests => 7;

diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

{
    no strict "refs";
    *t_func = \&WWW::NicoSound::Download::_make_unique_name;
}

my $name = t_func( );
ok( defined $name, "_make_unique_name returns defined value." );

my( $first, $second, $third )
    = map { t_func( ) }
      ( 1 .. 3 );
isnt( $first,  undef, "Data was defined" );
isnt( $second, undef, "Data was defined" );
isnt( $third,  undef, "Data was defined" );
isnt( $first,  $second, "Data is unique" );
isnt( $first,  $third,  "Data is unique" );
isnt( $second, $third,  "Data is unique" );

