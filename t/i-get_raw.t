use utf8;
use strict;
use warnings;
use bytes ( );
use WWW::NicoSound::Download qw( can_find_homepage get_raw );

use Test::More;
use Test::Exception;

# Can test? The environment can not reach to the server, then can not test.
eval { can_find_homepage( ) };

if ( my $e = Exception::Class->caught( "E::CantFindHomepage" ) ) {
    plan skip_all
        => "This environment can not reach to the NicoSound service in default(180) seconds.";
}
else {
#    plan tests => 4;
    plan skip_all => "This takes time too much, and might fail by the state of the server";
}

#diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

my $min_size = 1_000_000;
my $uri      = "http://nicosound.anyap.info/sound/sm7402975";
my $raw_ref;
my $id;

# Load MP3 to the memory.
$raw_ref = eval { get_raw( $uri ) };

# Given state of the server, when is overworking then pass,
# when is not overworking and returns error then fail,
# when can get raw then test it.
if ( my $e = Exception::Class->caught( "E::Overworking" ) ) {
    ok( 1, "The NicoSound server is overworking." );
}
elsif ( $@ ) {
    ok( 0, "Failed though the server is'nt overworking.[$@]" );
}
else {
    subtest "Succeed get_raw, then test it." => sub {
        plan tests => 2;

        is( ref $raw_ref, ref do { my $hoge; \$hoge } );
        cmp_ok( bytes::length( $$raw_ref ), ">", $min_size );
    };
}

# Die if invalid ID.
throws_ok { get_raw( ) }     "E::IDRequired";
$id = "a";
throws_ok { get_raw( $id ) } "E::InvalidURL";
$id = "sm4302920"; # Japanese title of ID: [ 遠くまで ]
throws_ok { get_raw( $id ) } "E::HasBeenDeleted";

