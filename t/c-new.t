use utf8;
use WWW::NicoSound::Download;
use Test::More tests => 1;

my $class = "WWW::NicoSound::Download";
my $downloader = $class->new;

isa_ok( $downloader, $class );

