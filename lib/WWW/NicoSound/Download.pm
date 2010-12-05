package WWW::NicoSound::Download;

use utf8;
use strict;
use warnings;
use Carp qw( croak );
use Readonly;
use base "Class::Accessor";
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::DOM;
use WWW::NicoSound::Download::Sound;

use constant IS_RIOT => 0;
use constant TIMEOUT => 10;
use constant DEBUG   => 0;

our $VERSION = "1.11";

Readonly my $MIN_BYTES => 1_000; # MP3 file should larger than this.
Readonly my %DEFAULT   => (
    ua      => LWP::UserAgent->new(
        timeout => TIMEOUT,
    ),
    is_riot => IS_RIOT,
    debug   => DEBUG,
);

#
# Class methods.
#

__PACKAGE__->mk_accessors(
    qw( ua  jar  is_riot  debug  sound ),
);

sub new {
    my $class = shift;
    my $self  = bless { }, $class;

    foreach my $name ( qw( ua is_riot debug ) ) {
        $self->_set_default( $name );
    }

    return $self;
}

sub url_to_id {
    my $class = shift;
    my $url   = shift
        or croak "URL required.";

    return eval { WWW::NicoSound::Download::Sound->new( url => $url )->id };
}

#
# Instance methods.
#

sub _set_default {
    my $self     = shift;
    my $property = shift
        or croak "Property required.";

    unless ( defined $self->$property ) {
        $self->$property( $DEFAULT{ $property } );
    }

    return $self;
}

sub save {
    my $self     = shift; 
    my %param    = @_;
    my $id       = $param{id};
    my $url      = $param{url};
    my $filename = $param{filename};

    my $sound = do {
        my %new;

        foreach my $key ( qw( id url filename ) ) {
            $new{ $key } = $param{ $key }
                if exists $param{ $key };
        }
        WWW::NicoSound::Download::Sound->new( %new );
    };

    $self->prepare( $sound );

    warn sprintf "--- Starting save_mp3[%s].\n", $sound->filename
        if $self->is_riot;

    my $res = $self->ua->get(
        $sound->sound_url,
        ":content_file" => $sound->filename,
    );

    if ( $res->is_error ) {
        die sprintf "Could not get MP3 data.[%d]", $res->status_line;
    }

    unless ( -f $sound->filename ) {
        die sprintf "Could not save MP3 data.[%s]", $sound->id;
    }

    # I hope the NicoSound server returns failure-code of HTTP-status.
    # Now, the server does not return failure code,
    # but returns HTML that the failure withers.
    if ( -T $sound->filename || -s $sound->filename < $MIN_BYTES ) {
=for comment
        unlink $sound->filename
            or die sprintf "The NicoSound server is overworking.\n"
                           . "Because of this, the downloaded file is not MP3 data.\n"
                           . "So I tried deleting, but it has failed.\n"
                           . "Please delete the file[%s].", $self->filename;
=cut

        die sprintf "The NicoSound server is overworking.\n"
                    . "### Try downloading later.[%s]", $sound->id;
    }

    return $sound;
}

sub prepare {
    my $self  = shift;
    my $sound = shift;

    croak "Sound required."
        unless $sound;

    # Pre-GET for save MP3.
    my $res = $self->ua->get( $sound->info_url );

    if ( $res->is_error ) {
        die sprintf "Failed pre GET that needs for get MP3.[%s]", $res->status_line;
    }

    warn "--- Succeeded first GET.\n"
        if $self->is_riot;

    # Can not get MP3 cause NicoSound web service.
    if ( $res->content =~ m{ video_deleted [.] jpg }imsx ) {
        die sprintf "The ID has been deleted.[%s]", $sound->id;
    }

    # Parse HTML.
    my $dom = HTML::DOM->new;
    $dom->write( $res->decoded_content );
    $dom->close;

    # Get title for filename.
    my $title = $dom->getElementsByTagName( "title" )->[0]->text;
    $title =~ s{\A \s* }{}msx;
    $title =~ s{ \s* \z}{}msx;
    my $hosi = "☆";
    my $nico = "にこ" . $hosi . "さうんど＃";
    $title =~ s{ [ ][-][ ]$nico .* }{}msx;
    $title =~ s{ [/] }{／}gmsx;

    # Did get title?
    if ( $title ) {
        $sound->title( $title );
    }
    else {
        die sprintf "Could not parse title from HTML.[%s]", $sound->id;
    }

    unless ( defined $sound->filename ) {
        $sound->parse_filename_from_title;
    }

    if ( -e $sound->filename ) {
        die sprintf "The file already exists.[%s]", $sound->filename;
    }

    warn sprintf "--- Title is [%s].\n", $sound->title
        if $self->is_riot;

    # The most important codes for NicoSound web service.
    # Cookies require for obtaining from NicoSound web service.
    # The flow of obtaining is:
    #   - GET  http://nicosound.anyap.info/sound/sm0000000
    #   - POST http://nicosound.anyap.info/sound/sm0000000
    #   - GET  http://nicosound2.anyap.info:8080/sound/sm0000000.mp3

    my $element_id    = "ctl00_ContentPlaceHolder1_SoundInfo1_btnLocal2";
    my( $post_param ) = grep { $_->id eq $element_id }
                        $dom->getElementsByTagName( "a" );

    # Does defined POST parameter?
    unless ( defined $post_param ) {
        die sprintf "Could not parse the parameters for POST.[%s]", $sound->id;
    }

    my( $event_target, $event_argument )
        = $post_param->href =~ m{ __doPostBack [(] ['] ([^']+) ['] [,] ['] ([^']*) }msx;

    # Does defined event target?
    unless ( $event_target ) {
        die sprintf "Could not parse the parameters for POST.[%s] - [%s]",
            $sound->id, $event_target;
    }

    my $cookie_jar = HTTP::Cookies->new;

    $res = $self->ua->post(
        $sound->info_url,
        {
            __EVENTTARGET   => $event_target,
            __EVENTARGUMENT => $event_argument,
        },
    );

    die "Status line isnt 302."
        if $self->debug && $res->status_line !~ m{302};

    warn "--- Succeeded the POST.\n"
        if $self->is_riot;

    $cookie_jar->extract_cookies( $res );

    if ( $cookie_jar ) {
        $self->ua->cookie_jar( $cookie_jar );
    }
    else {
        die "No jar."
            if $self->debug;
    }

    return $self;
}

1;

__END__
=encoding utf-8

=head1 NAME

WWW::NicoSound::Download - Save MP3 file from nicosound

=head1 SYNOPSIS

  use WWW::NicoSound::Download;

  my $url = "http://nicosound.anyap.info/sound/smXXXXXXXX";

  my $downloader = WWW::NicoSound::Download->new;

  my $sound = $downloader->save( url => $url );

  print $sound->filename, "\n";

  use Path::Class qw( file );
  use HTML::SimpleLinkExtor;

  my $extor = HTML::SimpleLinkExtorj->new;
  my $html  = do {
      my $raw = file( "result_page_of_searching_from_nicosound.html" )->slurp;
      utf8::decode( $raw );
      $raw;
  };
  my @urls = do {
      $extor->parse( $raw );
      $extor->links;
  };
  my @ids = map { WWW::NicoSound::Download->url_to_id( $_ ) } @urls;

=head1 DESCRIPTION

This class is for downloading MP3 files from nicosound web service.

=head1 CLASS METHODS

=over

=item new

Returns a new instance of Downloader.

=item url_to_id

Parses and returns nicosound ID from url.

=back

=head1 INSTANCE METHODS

=over

=item save

Downloads a MP3 from nicosound, and returns instance of WWW::NicoSound::Download::Sound.

=back

=head1 PROPERTIES

=over

=item ua

Specifies a LWP::UserAgent's instance.

=item is_riot

is specified, report message what i'm doing.

=item debug

Tells me work strictry.

=back

=head1 SEE ALSO

The homepage URL of NicoSound is "http://nicosound.anyap.info/"

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Kuniyoshi Kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

