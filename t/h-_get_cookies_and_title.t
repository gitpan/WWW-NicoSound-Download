use utf8;
use strict;
use warnings;
use LWP::UserAgent;
use WWW::NicoSound::Download qw( can_find_homepage );

use Test::More;
use Test::Exception;

# Can test? The environment can not reach to the server, then can not test.
eval { can_find_homepage( ) };

if ( my $e = Exception::Class->caught( "E::CantFindHomepage" ) ) {
    plan skip_all
        => "This environment can not reach to the NicoSound service in default(180) seconds.";
}
else {
    plan tests => 2;
}

#diag( "This test targets the version[$WWW::NicoSound::Download::VERSION]." );

# Install target method.
{
    no strict "refs";
    *t_func = \&WWW::NicoSound::Download::_get_cookies_and_title;
}

my $ua = LWP::UserAgent->new;
my $id;
my $expected_title = "Do As Infinity　生まれゆくものたちへ　【最高音質・320kbps】";

# Test OK case.
$id = "sm7402975"; # Japanese title: [ 生まれゆくものたちへ ]
lives_and(
    sub {
        is( ( t_func( $ua, $id ) )[1], $expected_title )
    }
);

# Test NG case.
$id = "sm4302920";  # Japanese title: [ 遠くまで ]
throws_ok { t_func( $ua, $id ) } "E::HasBeenDeleted";

