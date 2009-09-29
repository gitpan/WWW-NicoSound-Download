use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WWW::NicoSound::Download',
    VERSION_FROM      => 'lib/WWW/NicoSound/Download.pm', # finds $VERSION
    PREREQ_PM         => {
        "HTML::DOM"    => "0.026",
        "Carp::Assert" => "0",
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WWW/NicoSound/Download.pm', # retrieve abstract from module
       AUTHOR         => 'Kuniyoshi Kouji <kuniyoshi.kouji@indigo.plala.or.jp>') : ()),
);

