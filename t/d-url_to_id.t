use WWW::NicoSound::Download;
use Test::More tests => 1;

my @urls = qw(
    http://nicosound.anyap.info/sound/sm5546220
    http://nicosound.anyap.info/sound/sm8686306
);

my @ids = map { WWW::NicoSound::Download->url_to_id( $_ ) } @urls;

is( 2, scalar @ids );


