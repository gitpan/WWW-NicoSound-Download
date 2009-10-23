use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use WWW::NicoSound::Download ( );
use Test::More tests => 15;

diag( "The target version is: " . $WWW::NicoSound::Download::VERSION );

my @invalid_ids = (
    undef,
    0,
    "",
    " ",
    qw(
        asdf
        sm0000
        sm0000000000
        nm0000
        nm0000000000
        pm000000
        pm0000000
    ),
);

my @valid_ids = qw(
    sm123456
    sm1234567
    nm123456
    nm1234567
);

INVALID_CASE:
foreach my $id ( @invalid_ids ) {
    is( WWW::NicoSound::Download::_is_id_valid( $id ), undef );
}

VALID_CASE:
foreach my $id ( @valid_ids ) {
    is( WWW::NicoSound::Download::_is_id_valid( $id ), 1 );
}

