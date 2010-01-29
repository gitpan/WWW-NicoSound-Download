use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download qw( can_find_homepage );

use Test::More tests => 1;

eval { can_find_homepage( ) };

if ( my $e = Exception::Class->caught( "E::CantFindHomepage" ) ) {
    ok( 1, "throw if can not find homepage" );
}
elsif ( $@ ) {
    ok( 0, "error isa Exception::Class.[$@]" );
}
else {
    ok( 1, "can find homepage" );
}

