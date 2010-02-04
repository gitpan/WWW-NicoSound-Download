use ExtUtils::MakeMaker;


WriteMakefile(
    NAME              => 'WWW::NicoSound::Download',
    VERSION_FROM      => 'lib/WWW/NicoSound/Download.pm',
    PREREQ_PM         => {
        "HTML::DOM"        => "0.034",
        "Carp::Assert"     => 0,
        "Exception::Class" => 0,
        "Test::More"       => "0.94",
        "Test::Exception"  => 0,
        "Test::File"       => 0,
    },
    LICENSE           => 'perl',
    ABSTRACT_FROM     => 'lib/WWW/NicoSound/Download.pm',
    AUTHOR            => 'Kuniyoshi Kouji <kuniyoshi@cpan.org>',
);

