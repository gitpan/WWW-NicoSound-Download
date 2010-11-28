use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download::Sound;
use Test::More;
use Test::Exception;

my @valid_cases = (
    [ "http://nicosound.anyap.info/sm1234567",        "sm1234567"  ],
    [ "http://nicosound.anyap.info/nm7654321/a",      "nm7654321"  ],
    [ "http://nicosound.anyap.info/nm123456/3",       "nm123456"   ],
    [ "http://nicosound.anyap.info/sm654321/",        "sm654321"   ],
    [ "http://nicosound.anyap.info/sound/zb1234567",  "zb1234567"  ],
    [ "http://nicosound.anyap.info/sound/zb654321",   "zb654321"   ],
    [ "http://nicosound.anyap.info/sound/sm10000816", "sm10000816" ],

    # ID is valid too.
    [ "sm1234567",                                   "sm1234567"  ],
    [ "nm1234567",                                   "nm1234567"  ],
    [ "zb123456",                                    "zb123456"   ],
    [ "sm123456",                                    "sm123456"   ],
    [ "nm123456",                                    "nm123456"   ],
    [ "zb1234567",                                   "zb1234567"  ],
    [ "sm10000816",                                  "sm10000816" ],
    [ "   nm123456  ",                               "nm123456"   ],
    [ "\tnm1234567\t",                               "nm1234567"  ],
    [ " \t sm7654321\t \t",                          "sm7654321"  ],
);

my @invalid_uris = (
    undef,
    "",
    0,
    10,
    "01",
    qw(
        http://nicosound.anyap.info/something/but/otherthing/id9320971
        http://nicosound.anyap.info/id9320971
        http://nicosound.anyap.info/nm19320
        http://nicosound.anyap.info/sm123456789
    ),
);

my $tests = 2 * @valid_cases;
$tests += @invalid_uris;
plan tests => $tests;

#diag( "The number of valid cases is: ", scalar @valid_cases );

TEST_VALID_CASES:
foreach my $case_ref ( @valid_cases ) {
    my( $uri, $wish ) = @{ $case_ref };

    my $sound = eval { WWW::NicoSound::Download::Sound->new( url => $uri ) };
    isa_ok( $sound, "WWW::NicoSound::Download::Sound", "$uri - $wish" );
    is( eval { $sound->id }, $wish, "$uri - $wish" );
}

#diag( "The number of invalid cases is: ", scalar @invalid_uris );

TEST_INVALID_URI:
foreach my $uri ( @invalid_uris ) {
    dies_ok( sub { WWW::NicoSound::Download::Sound->new( url => $uri ) } );
}

