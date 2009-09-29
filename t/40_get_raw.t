use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More skip_all => "It takes time too much.";# tests => 3;

use WWW::NicoSound::Download qw( get_raw );


my $url      = "http://nicosound.anyap.info/sound/sm7402975";
my $raw_ref  = get_raw( $url );
my $min_size = 1_000_000;

ok( defined $raw_ref, "Function does not return undef value" );
is( ref $raw_ref, "SCALAR", "The return value is scalar reference." );
{
    use bytes;
    cmp_ok( bytes::length $$raw_ref, ">", $min_size, "The return value has length." );
}

