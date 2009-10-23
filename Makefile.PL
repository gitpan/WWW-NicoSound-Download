use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'WWW::NicoSound::Download',
    VERSION_FROM      => 'lib/WWW/NicoSound/Download.pm',
    PREREQ_PM         => {
        "HTML::DOM"       => "0.026",
        "Carp::Assert"    => "0",
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WWW/NicoSound/Download.pm', # retrieve abstract from module
       AUTHOR         => 'Kuniyoshi Kouji <kuniyoshi.kouji@indigo.plala.or.jp>') : ()),
);

