use WWW::NicoSound::Download;
use Test::More tests => 1;

my $module  = "WWW::NicoSound::Download";
my @methods = qw(
    new
    url_to_id
    _set_default
    save
    prepare
);

can_ok( $module, @methods );

