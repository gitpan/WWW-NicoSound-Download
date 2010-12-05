use ExtUtils::MakeMaker;


WriteMakefile(
    NAME              => 'WWW::NicoSound::Download',
    VERSION_FROM      => 'lib/WWW/NicoSound/Download.pm',
    PREREQ_PM         => {
        "Readonly"         => 0,
        "Class::Accessor"  => 0,
        "HTML::DOM"        => "0.034",
        "Test::Exception"  => 0,
    },
    LICENSE           => 'perl',
    ABSTRACT_FROM     => 'lib/WWW/NicoSound/Download.pm',
    AUTHOR            => 'Kuniyoshi Kouji <kuniyoshi@cpan.org>',
);

