use utf8;
use open ":utf8";
use open ":std";
use strict;
use warnings;
use LWP::UserAgent;
use WWW::NicoSound::Download ( );
use Test::More tests => 9;

diag( "The target version is: " . $WWW::NicoSound::Download::VERSION );

# Install target method.
{
    no strict "refs";
    *func = \&WWW::NicoSound::Download::_get_cookies_and_title;
}

# Test OK case.
my $ua = LWP::UserAgent->new( );
my $id = "sm7402975";  # Japanese title: [ 生まれゆくものたちへ ]
my $expected_title = "Do As Infinity　生まれゆくものたちへ　【最高音質・320kbps】";

my( $cookie_jar, $title ) = eval { func( $ua, $id ) };

is( $@, "", "Does not die." );

isnt( $cookie_jar, undef, "Got value." );
isnt( $title,      undef, "Got value." );

is( $title, $expected_title, "Title can get." );

isnt( ref $cookie_jar, "", "Cookie_jar is reference." );
is( ref $cookie_jar, "HTTP::Cookies", "Cookie_jar is HTTP::Cookies." );

# Test NG case.
$id = "sm4302920";  # Japanese title: [ 遠くまで ]
( $cookie_jar, $title ) = eval { func( $ua, $id ) };
isnt( $@, "", "Did die." );
is( $cookie_jar, undef, "Did not get value." );
is( $title,      undef, "Did not get value." );

