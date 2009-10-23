use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use WWW::NicoSound::Download ( );
use Test::More tests => 7;

my $name = WWW::NicoSound::Download::_make_unique_name( );
ok( defined $name, "_make_unique_name returns defined value." );

my( $first, $second, $third )
    = map { WWW::NicoSound::Download::_make_unique_name( ) }
      ( 1 .. 3 );
isnt( $first,  undef, "Data was defined" );
isnt( $second, undef, "Data was defined" );
isnt( $third,  undef, "Data was defined" );
isnt( $first,  $second, "Data is unique" );
isnt( $first,  $third,  "Data is unique" );
isnt( $second, $third,  "Data is unique" );

