use ExtUtils::MakeMaker;


WriteMakefile(
    NAME              => 'WWW::NicoSound::Download',
    VERSION_FROM      => 'lib/WWW/NicoSound/Download.pm',
    PREREQ_PM         => {
        "HTML::DOM"        => "0.034",
        "Test::Exception"  => 0,
    },
    LICENSE           => 'perl',
    ABSTRACT_FROM     => 'lib/WWW/NicoSound/Download.pm',
    AUTHOR            => 'Kuniyoshi Kouji <kuniyoshi@cpan.org>',
);

