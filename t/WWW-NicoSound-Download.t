#!/usr/bin/perl

use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use Test::More tests => 26;

BEGIN { use_ok("WWW::NicoSound::Download") };
my $MODULE_NAME = "WWW:NicoSound::Download";
BEGIN { use_ok("WWW::NicoSound::Download", qw(get_id get_raw save_mp3 get_ids)) };
my @methods = qw(get_id get_raw save_mp3 get_ids);

my $tname   = "";


#########
$tname = "get_id - Parse nico id.";
#########
my $wish = "sm1234567";
my $url  = "http://nicosound.anyap.info/$wish";
is( get_id($url), $wish, $tname );
$wish    = "nm7654321";
$url     = "http://nicosound.anyap.info/$wish\a";
is( get_id($url), $wish, $tname );
$wish    = "nm123456";
$url     = "http://nicosound.anyap.info/$wish\3";
is( get_id($url), $wish, $tname );
$wish    = "sm654321";
$url     = "http://nicosound.anyap.info/$wish/";
is( get_id($url), $wish, $tname );

#########
$tname = "get_id - Return undef if ID is invalid.";
#########
$url = "http://nicosound.anyap.info/something/but/otherthing/id9320971";
is( get_id($url), undef, $tname );
$url = "http://nicosound.anyap.info/id9320971";
is( get_id($url), undef, $tname );
$url = "http://nicosoun1d.anyap.info/sm19320971";
is( get_id($url), undef, $tname );
$url = "http://nicosound.anyap.info/nm19320";
is( get_id($url), undef, $tname );


SKIP: {
    skip "It takes too much.", 3;

#########
$tname = "get_raw - Get mp3 in memory.";
#########
$url        = "http://nicosound.anyap.info/sound/sm7402975";
my $id      = get_id($url);
my $raw_ref = get_raw($id);
ok( defined $raw_ref, $tname );
is( ref $raw_ref, "SCALAR", $tname );
{
    use bytes;
    cmp_ok( bytes::length $$raw_ref, ">", 1_000_000, $tname );
}

}


SKIP: {
    skip "It takes too much.", 9;

#########
$tname = "save_mp3 - Using default name.";
#########
my $id = "sm7402975";
my $filename = save_mp3($id);
ok( defined $filename, $tname."  Check defined." );
ok( -f $filename, $tname."  File exists." );
my $size = -s $filename;
cmp_ok( $size, ">", 1_000_000, $tname."  Check size." );
unlink $filename;
ok( !-e $filename, $tname."  Unlinked." );

#########
$tname = "save_mp3 - Two or more times can do?";
#########
my @ids = qw( sm7461448 sm7461357 );
my $first_name  = save_mp3(shift @ids);
my $second_name = save_mp3(shift @ids);
isnt( $first_name, $second_name, $tname );
unlink $first_name, $second_name;

#########
$tname = "save_mp3 - Using ordered name.";
#########
$filename = "anything.mp3";
$id = "sm7461448";
is( save_mp3($id, $filename), $filename, $tname."  It returns filename." );
ok( -f $filename, $tname."  Is exists?" );
cmp_ok( -s $filename, ">", 1_000_000, $tname."  Check size." );
unlink $filename;
ok( !-e $filename, $tname."  Unlinked." );

}


#########
$tname = "get_ids - Get tagged ids.";
#########
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
my @ids         = get_ids($web_page);
isnt( @ids, 0, $tname."  Something ware got." );
is( (grep { m{\A [ns]m \d{6,7} \z}msx } @ids), @wish, $tname."  Check counting ID." );
ok( eq_set(\@ids, \@wish), $tname."  Eq set." );
is_deeply( \@ids, \@wish, $tname."  Match ids" );


