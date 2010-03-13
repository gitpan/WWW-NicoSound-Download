use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download ( );

use Test::More tests => 23;
use Test::Exception;

#diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

{
    no strict "refs";
    *t_func = \&WWW::NicoSound::Download::_is_id_valid;
}

my @invalid_ids = (
    undef,
    0,
    "",
    " ",
    qw(
        asdf
        sm0000
        sm1234567890
        nm0000
        nm1234567890
        pm000000
        pm0000000
        so123456789
    ),
);

my @valid_ids = qw(
    sm123456
    sm1234567
    nm123456
    nm1234567
    zb123456
    zb1234567
    so123456
    so1234567
    sm10002804
    sm12345678
);

throws_ok { t_func( ) } "E::IDRequired";

#diag( "The number of invalid cases is: ", scalar @invalid_ids );

INVALID_CASE:
foreach my $id ( @invalid_ids ) {
    throws_ok { t_func( $id ) } "E::InvalidID";
}

#diag( "The number of valid cases is: ", scalar @valid_ids );

VALID_CASE:
foreach my $id ( @valid_ids ) {
    lives_ok { t_func( $id ), "The id is: $id" };
}

