use utf8;
use strict;
use warnings;
use WWW::NicoSound::Download qw( can_find_homepage save_mp3 );

use Test::More;
if ( can_find_homepage( ) ) {
    #plan tests => 37;
    plan skip_all => "This takes time too much.";
}
else {
    plan skip_all
        => "This environment can not reach to the NicoSound service in default(180) seconds.";
}

diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

my @valid_ids = (
    "sm7402975",  # Japanese title: [ 生まれゆくものたちへ ]
    "http://nicosound.anyap.info/sm7461357",  # Japanese title: [ メラメラ ]
);

my @cant_view_ids = (
    "sm4302920",  # Japanese title: [ 遠くまで ]
    "http://nicosound.anyap.info/sound/sm3448715",  # Japanese title: [ 柊 ]
);

my @invalid_ids = (
    "ax363024",  # Does not exist.
);

my $min_file_size = 1_000_000;


INVALID_CASE:
foreach my $invalid_id ( @invalid_ids ) {
    my $undef = eval { save_mp3( $invalid_id ) };

    is( $undef, undef, "Returns undef in failure." );
    isnt( $@, "", "The save_mp3 died." );
}

CANT_VIEW:
foreach my $cant_view_id ( @cant_view_ids ) {
    my $undef = eval { save_mp3( $cant_view_id ) };

    is( $undef, undef, "Returns undef in failure." );
    isnt( $@, "", "The save_mp3 died." );
    like( $@, qr/has be deleted/, "Message should set." );
}

CAN_SAVE:
foreach my $valid_id ( @valid_ids ) {
    my $filename = eval { save_mp3( $valid_id ) };

    SKIP: {
        skip "The server is overworking.", 6
            if $@ =~ m{server is overworking};

        is( $@, "", "Saving succeeded." );
        tests_in_ok_cases( $filename );
    };
}

# Tow files can save with unique name?
my $first_name  = eval { save_mp3( $valid_ids[0] ) };
my $is_overworking = $@ =~ m{server is overworking};
my $second_name = eval { save_mp3( $valid_ids[1] ) };

SKIP: {
    skip "The server is overworking.", 11
        if $is_overworking or $@ =~ m{server is overworking};

    isnt( $first_name, $second_name, "save_mp3 - Two or more times can do?" );
    tests_in_ok_cases( $first_name );
    tests_in_ok_cases( $second_name );
};
unlink $first_name
    if -e $first_name;
unlink $second_name
    if -e $second_name;

# Specify filename.
my $filename = "anything.mp3";
my $id  = $valid_ids[0];
my $got = eval { save_mp3( $id, $filename ) };

SKIP: {
    skip "The server is overworking.", 6
        if $@ =~ m{server is overworking};

    is( $got, $filename, "Can specify filename." );
    tests_in_ok_cases( $got );
};


sub tests_in_ok_cases {
    my $filename = shift;

    ok( defined $filename, "Function does not return undef value." );
    ok( -f $filename,      "Function returns filename." );
    ok( -B $filename,      "File is binary." );
    cmp_ok( -s $filename,  ">", $min_file_size, "File is not dummy file." );

    unlink $filename;

    ok( ! -e $filename,    "Can unlink." );
}

