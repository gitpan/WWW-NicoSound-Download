use strict;
use warnings;
use WWW::NicoSound::Download qw( get_id );

use Test::More tests => 15;

diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

my @valid_cases = (
    [ "http://nicosound.anyap.info/sm1234567",   "sm1234567" ],
    [ "http://nicosound.anyap.info/nm7654321/a", "nm7654321" ],
    [ "http://nicosound.anyap.info/nm123456/3",  "nm123456"  ],
    [ "http://nicosound.anyap.info/sm654321/",   "sm654321"  ],

    # ID is valid too.
    [ "sm1234567",                               "sm1234567" ],
    [ "nm1234567",                               "nm1234567" ],
    [ "sm123456",                                "sm123456"  ],
    [ "nm123456",                                "nm123456"  ],
    [ "   nm123456  ",                           "nm123456"  ],
    [ "\tnm1234567\t",                           "nm1234567" ],
    [ " \t sm7654321\t \t",                      "sm7654321" ],
);

my @invalid_uris = qw(
    http://nicosound.anyap.info/something/but/otherthing/id9320971
    http://nicosound.anyap.info/id9320971
    http://nicosoun1d.anyap.info/sm19320971
    http://nicosound.anyap.info/nm19320
);

TEST_VALID_CASES:
foreach my $case_ref ( @valid_cases ) {
    my( $uri, $wish ) = @{ $case_ref };

    is( get_id( $uri ), $wish, "In valid case." );
}

TEST_INVALID_URI:
foreach my $uri ( @invalid_uris ) {
    is( get_id( $uri ), undef, "Returns undef if invalid." );
}

