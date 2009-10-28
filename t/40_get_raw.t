use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download qw( can_find_homepage get_raw );

use Test::More;

if ( can_find_homepage( ) ) {
    #plan tests => 8;
    plan skip_all => "This takes time too much.";
}
else {
    plan skip_all
        => "This environment can not reach to the NicoSound service in default(180) seconds.";
}

diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

my $min_size = 1_000_000;
my $uri      = "http://nicosound.anyap.info/sound/sm7402975";
my $raw_ref  = eval { get_raw( $uri ) };

SKIP: {
    skip "The server is overworking.", 4
        if $@ =~ m{server is overworking};

    is( $@, "", "The get_raw did not die." );
    ok( defined $raw_ref, "Function does not return undef value" );
    is( ref $raw_ref, "SCALAR", "The return value is scalar reference." );
    {
        use bytes;
        cmp_ok( bytes::length $$raw_ref, ">", $min_size, "The return value has length." );
    }
};

# Die if invalid ID.
$raw_ref = eval { get_raw( "invalid" ) };
isnt( $@, "", "The get_raw died." );
is( $raw_ref, undef, "The get_raw returned undef." );

# Die if ID has be deleted.
$raw_ref = eval { get_raw( "sm4302920" ) }; # Japanese title of ID: [ 遠くまで ]

SKIP: {
    skip "The server is overworking.", 2
        if $@ =~ m{server is overworking};

    isnt( $@, "", "The get_raw died." );
    is( $raw_ref, undef, "The get_raw returned undef." );
};

