use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More skip_all => "It takes time too much.";#tests => 38;

use WWW::NicoSound::Download qw( save_mp3 );


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
    my $undef = save_mp3( $invalid_id );

    is( $undef, undef, "ID is invalid." );
}

CANT_SAVE:
foreach my $cant_view_id ( @cant_view_ids ) {
    my $filename = save_mp3( $cant_view_id );

    ok( defined $filename, "Function does not return undef value." );
    ok( -f $filename,      "Function returns filename." );
    ok( -T $filename,      "File is text." );
    cmp_ok( -s $filename, "<", $min_file_size, "File is dummy." );

    unlink $filename;
    ok( !-e $filename,     "Succeeded unlink." );
}

CAN_SAVE:
foreach my $valid_id ( @valid_ids ) {
    my $filename = save_mp3( $valid_id );

    tests_in_ok_cases( $filename );
}


my( $first_name, $second_name ) = map { save_mp3( $_ ) }
                                  @valid_ids[ 0 .. 1 ];
isnt( $first_name, $second_name, "save_mp3 - Two or more times can do?" );
tests_in_ok_cases( $first_name );
tests_in_ok_cases( $second_name );


my $filename = "anything.mp3";
my $id = $valid_ids[0];
is( save_mp3($id, $filename), $filename, "Specify filename." );
tests_in_ok_cases( $filename );




sub tests_in_ok_cases {
    my $filename = shift;

    ok( defined $filename, "Function does not return undef value." );
    ok( -f $filename,      "Function returns filename." );
    ok( -B $filename,      "File is binary." );
    cmp_ok( -s $filename, ">", $min_file_size, "File is not dummy file." );

    unlink $filename;
    ok( !-e $filename,     "Succeeded unlink." );
}

