use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More skip_all => "It takes time too much.";
#use Test::More tests => 37;

use WWW::NicoSound::Download qw( save_mp3 );
diag( "The target version is: $WWW::NicoSound::Download::VERSION" );


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
    local $@;
    my $undef = eval { save_mp3( $invalid_id ) };

    is( $undef, undef, "Returns undef in failure." );
    ok( defined $@, "ID is invalid." );
}

CANT_SAVE:
foreach my $cant_view_id ( @cant_view_ids ) {
    local $@;
    my $undef = eval { save_mp3( $cant_view_id ) };

    is( $undef, undef, "Returns undef in failure." );
    ok( defined $@, "Failed and died." );
    like( $@, qr/has be deleted/, "Message should set." );
}

CAN_SAVE:
foreach my $valid_id ( @valid_ids ) {
    local $@;
    my $filename = eval { save_mp3( $valid_id ) };

    is( $@, "", "Saving succeeded." );
    tests_in_ok_cases( $filename );
}


my( $first_name, $second_name ) = map { eval { save_mp3( $_ ) } }
                                  @valid_ids[ 0 .. 1 ];
isnt( $first_name, $second_name, "save_mp3 - Two or more times can do?" );
tests_in_ok_cases( $first_name );
tests_in_ok_cases( $second_name );


my $filename = "anything.mp3";
my $id = $valid_ids[0];
is( eval { save_mp3($id, $filename) }, $filename, "Can specify filename." );
tests_in_ok_cases( $filename );

# TODO:
# If the NicoSound server is overworking,
# the save_mp3 will fail, but can not test it.


sub tests_in_ok_cases {
    my $filename = shift;

    ok( defined $filename, "Function does not return undef value." );
    ok( -f $filename,      "Function returns filename." );
    ok( -B $filename,      "File is binary." );
    cmp_ok( -s $filename, ">", $min_file_size, "File is not dummy file." );

    unlink $filename;
    ok( !-e $filename,     "Can unlink." );
}

