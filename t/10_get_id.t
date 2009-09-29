#!/usr/bin/perl

use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More tests => 15;

use WWW::NicoSound::Download qw( get_id );


my @cases = (
    # Valid cases.
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
    [ "\tnm1234567\t",                            "nm1234567" ],
    [ " \t sm7654321\t \t",                      "sm7654321" ],


    # Invalid cases.
    [ "http://nicosound.anyap.info/something/but/otherthing/id9320971", undef ],
    [ "http://nicosound.anyap.info/id9320971",                          undef ],
    [ "http://nicosoun1d.anyap.info/sm19320971",                        undef ],
    [ "http://nicosound.anyap.info/nm19320",                            undef ],
);


foreach my $case_ref ( @cases ) {
    my( $url, $wish ) = @{ $case_ref };
    is( get_id( $url ), $wish );
}

