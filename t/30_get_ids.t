use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More tests => 2;

use WWW::NicoSound::Download qw( get_ids );


my @wish     = qw(
    nm3150736
    nm3208627
    nm3381592
    nm3660851
    nm6488123
    sm1716076
    sm2425902
    sm3584956
    sm3805749
    sm3966366
    sm4441398
    sm4479239
    sm5110219
    sm5202662
    sm6465363
    sm7066484
    sm7239098
    sm7461357
    sm7461448
    sm7461507
);
my $web_page = "t/Do_As_Infinity.html";
my @ids      = get_ids( $web_page );


isnt( @ids, 0, "Got some ID" );
ok( eq_set( \@ids, \@wish ), "All expected ID was obtained." );

