use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More skip_all => "It takes time too much.";
#use Test::More tests => 7;

use WWW::NicoSound::Download qw( get_raw );
diag( "The target version is: " . $WWW::NicoSound::Download::VERSION );

my $url      = "http://nicosound.anyap.info/sound/sm7402975";
my $raw_ref  = eval { get_raw( $url ) };
my $min_size = 1_000_000;

ok( defined $raw_ref, "Function does not return undef value" );
is( ref $raw_ref, "SCALAR", "The return value is scalar reference." );
{
    use bytes;
    cmp_ok( bytes::length $$raw_ref, ">", $min_size, "The return value has length." );
}

# Die if invalid ID.
$raw_ref = eval { get_raw( "invalid" ) };
isnt( $@, "", "The get_raw died." );
is( $raw_ref, undef, "The get_raw returned undef." );

# Die if ID has be deleted.
$raw_ref = eval { get_raw( "sm4302920" ) }; # Japanese title of ID: [ 遠くまで ]
isnt( $@, "", "The get_raw died." );
is( $raw_ref, undef, "The get_raw returned undef." );

