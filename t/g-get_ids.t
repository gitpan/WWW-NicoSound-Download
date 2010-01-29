use utf8;
use strict;
use warnings;
use File::Spec::Functions qw( catfile );
use WWW::NicoSound::Download qw( get_ids );

use Test::More tests => 4;
use Test::Exception;

#diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

my $web_page;
my @wish = qw(
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

# Valid case.
$web_page = catfile( "t", "data", "Do_As_Infinity.html" );
lives_and(
    sub { ok( eq_set( [ get_ids( $web_page ) ], \@wish ) ) }
);

# File does not exist.
$web_page = catfile( "t", "data", "Does_not_exist_file" );
throws_ok { get_ids( $web_page ) } "E::FileDoesNotExist";

# No argument.
throws_ok { get_ids( ) } "E::FilenameRequired";

# Invalid filename.
throws_ok { get_ids( "" ) } "E::InvalidFilename";

