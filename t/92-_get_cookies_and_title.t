use utf8;
use strict;
use warnings;
use LWP::UserAgent;
use WWW::NicoSound::Download qw( can_find_homepage );

use Test::More;

if ( can_find_homepage( ) ) {
    plan tests => 9;
}
else {
    plan skip_all
        => "This environment can not reach to the NicoSound service in default(180) seconds.";
}

diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

# Install target method.
{
    no strict "refs";
    *t_func = \&WWW::NicoSound::Download::_get_cookies_and_title;
}

# Test OK case.
my $ua = LWP::UserAgent->new( );
my $id = "sm7402975";  # Japanese title: [ 生まれゆくものたちへ ]
my $expected_title = "Do As Infinity　生まれゆくものたちへ　【最高音質・320kbps】";

my( $cookie_jar, $title ) = eval { t_func( $ua, $id ) };

is( $@, "", "The func did not die." );

isnt( $cookie_jar, undef, "Got value." );
isnt( $title,      undef, "Got value." );

is( $title, $expected_title, "Title can get." );

isnt( ref $cookie_jar, "", "Cookie_jar is reference." );
is( ref $cookie_jar, "HTTP::Cookies", "Cookie_jar is HTTP::Cookies." );

# Test NG case.
$id = "sm4302920";  # Japanese title: [ 遠くまで ]

( $cookie_jar, $title ) = eval { t_func( $ua, $id ) };

isnt( $@, "", "Did die." );
is( $cookie_jar, undef, "Did not get value." );
is( $title,      undef, "Did not get value." );


