use utf8;
use strict;
use warnings;
use Encode qw( encode_utf8 );
use WWW::NicoSound::Download qw( can_find_homepage save_mp3 );

use Test::More;
use Test::Exception;
use Test::File;

# Can test? The environment can not reach to the server, then can not test.
eval { can_find_homepage( ) };

if ( my $e = Exception::Class->caught( "E::CantFindHomepage" ) ) {
    plan skip_all
        => "This environment can not reach to the NicoSound service in default(180) seconds.";
}
else {
#    plan tests => 17;
    plan skip_all => "This takes time too much, and might fail by the state of the server";
}

#diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

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

# No argument.
throws_ok { save_mp3( ) } "E::IDRequired";

INVALID_CASE:
foreach my $invalid_id ( @invalid_ids ) {
    throws_ok { save_mp3( $invalid_id ) } "E::InvalidURL";
}

CANT_VIEW:
foreach my $cant_view_id ( @cant_view_ids ) {
    throws_ok { save_mp3( $cant_view_id ) } "E::HasBeenDeleted";
}

CAN_SAVE:
foreach my $valid_id ( @valid_ids ) {
    my $filename = eval { save_mp3( $valid_id ) };

    if ( my $e = Exception::Class->caught( "E::Overworking" ) ) {
        ok( 1, "The server is overworking." );
    }
    elsif ( $@ ) {
        ok( 0, "The server is not overworking, but returns error.[$@]" );
    }
    else {
        subtest "Succeed saving, then start testing." => sub {
            plan tests => 2;

            file_min_size_ok( encode_utf8( $filename ), $min_file_size );
            unlink $filename;
            file_not_exists_ok( encode_utf8( $filename ) );
        }
    }
}

# Tow files can save with unique name?
##################################################################
### This test does [[[ not ]]] care the server is overworking. ###
##################################################################
my $first_name  = eval { save_mp3( $valid_ids[0] ) };
my $second_name = eval { save_mp3( $valid_ids[1] ) };

isnt( $first_name, $second_name );

file_min_size_ok( encode_utf8( $first_name ), $min_file_size );
unlink $first_name;
file_not_exists_ok( encode_utf8( $first_name ) );

file_min_size_ok( encode_utf8( $second_name ), $min_file_size );
unlink $second_name;
file_not_exists_ok( encode_utf8( $second_name ) );

# Specify filename.
my $filename = "anything.mp3";
my $id       = $valid_ids[0];
my $got      = eval { save_mp3( $id, $filename ) };

is( $got, $filename, "Can specify filename." );
file_min_size_ok( encode_utf8( $got ), $min_file_size );
unlink $got;
file_not_exists_ok( encode_utf8( $got ) );

# Duplicated name.
$id       = $valid_ids[0];
$filename = eval { save_mp3( $id ) };

file_min_size_ok( encode_utf8( $filename ), $min_file_size );

throws_ok { save_mp3( $id ) } "E::FileAlreadyExists";

unlink $filename;

file_not_exists_ok( encode_utf8( $filename ) );

