package WWW::NicoSound::Download;

use utf8;
use strict;
use warnings;
#use Carp::Assert;
no Carp::Assert;
use bytes ( );
use File::Spec::Functions qw( splitdir );
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::DOM;
use WWW::NicoSound::Download::Error;

require Exporter;

our @ISA         = qw( Exporter );
our %EXPORT_TAGS = ( all => [ qw(
    can_find_homepage  get_id  get_ids  get_raw  save_mp3  
) ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{all} } );
our @EXPORT      = ( );

our $VERSION = "1.06";
our $IS_RIOT = 0;

my $INFO_URL  = "http://nicosound.anyap.info/sound/";
my $SOUND_URL = "http://nicosound2.anyap.info:8080/sound/";
my $ID_LIKE   = "([ns]m|zb) \\d{6,7}";
my $MIN_SIZE  = 1_000;  # MP3 file should larger than this.
my $INDEX     = 0;

=head1 NAME

WWW::NicoSound::Download - Get mp3 file from NicoSound web service

=head1 SYNOPSIS

  use WWW::NicoSound::Download qw( can_find_homepage get_id get_ids get_raw save_mp3 );

  eval { can_find_homepage( ) };
  die $@
      if $@;

  eval {
      my $uri = "http://nicosound.anyap.info/sm0000000";
      my $id  = get_id( $url );

      save_mp3( $id );

      # Or get raw to the memory.
      my $raw_ref = get_raw( $id );
      # ..some modification.
  };

  # Get MP3 from a local-file of web-page.
  my @ids = eval { get_ids( "somepage.html" ) };
  die $@
      if $@;

  eval { save_mp3( $_ ) }
      foreach @ids;

  # To see module messages, set flag to true.
  $WWW::NicoSound::Download::IS_RIOT = 1;

=head1 DESCRIPTION

In this module, you can preserve a MP3 file from NicoSound.

NicoSound's URL is "http://nicosound.anyap.info/".

=head2 EXPORT

None by default.

=head1 METHODS

=over

=item can_find_homepage( )

This function tests that perl can reach to the NicoSound
in default(180) seconds.

=cut

sub can_find_homepage {
    my $ua  = LWP::UserAgent->new;
    my $res = $ua->get( $INFO_URL );

    if ( $res->is_success ) {
        return 1;
    }
    else {
        E::CantFindHomepage->throw(
            message     => "Could not reach to the server in 180[s].",
            status_line => $res->status_line,
        );
    }
}

=item get_id( "http://nicosound.anyap.info/sm0000000" )

This function parses URL, and returns NicoSound's ID.

=cut

sub _is_id_valid {
    unless ( @_ ) {
        E::IDRequired->throw(
            message => "ID required.",
        );
    }

    my $id = shift;
    $id = defined $id ? $id : "";

    return 1
        if $id =~ m{\A $ID_LIKE \z}msx;

    E::InvalidID->throw(
        message => "ID is invalid.",
        id      => $id,
    );
}

sub get_id {
    unless ( @_ ) {
        E::URLRequired->throw(
            message => "URL required.",
        );
    }

    my $url = shift;
    $url = $url ? $url : "";

    if ( $url =~ m{ ($ID_LIKE) (?:[^\d] | \z) }msx ) {
        my $id = $1;

        assert( _is_id_valid( $id ) )
            if DEBUG;

        return $id;
    }
    else {
        E::InvalidURL->throw(
            message => "URL is invalid.",
            url     => $url,
        );
    }
}

=item get_ids( "webpage.html" )

This function obtains some IDs from web page.
Web page is a HTML file that from NicoSound.

=cut

sub get_ids {
    unless ( @_ ) {
        E::FilenameRequired->throw(
            message => "Filename required.",
        );
    }

    my $filename = shift;
    $filename = $filename ? $filename : "";

    unless ( $filename ) {
        E::InvalidFilename->throw(
            message  => "Filename is invalid.",
            filename => $filename,
        );
    }

    unless ( -f $filename ) {
        E::FileDoesNotExist->throw(
            message  => "File does not exist, or it's not file.",
            filename => $filename,
        );
    }

    # Parse HTML file.
    my $dom = HTML::DOM->new;
    $dom->parse_file( $filename );

    my %link;

    GET_LINK_FROM_HTML:
    foreach my $href ( $dom->getElementsByTagName( "a" ) ) {
        my $id = eval { get_id( $href->href ) };

        if ( $id ) {
            $link{ $id }++;
        }
    }
#printf "The number of IDs is: [%d].\n", scalar keys %link;
#print join "\n", sort keys %link;

    warn "--- The number of parsed ID is: ", scalar( keys %link ), ".\n"
        if $IS_RIOT;

    return sort keys %link;
}

=item get_raw( "nm0000000" )

This function reads the MP3 data to the memory.
It is used to raw modification.
Use save_mp3 if only saving MP3 data.

=cut

sub get_raw {
    unless ( @_ ) {
        E::IDRequired->throw(
            message => "ID Required.",
        );
    }

    my $id = shift;

    # Is ID valid?
    eval { _is_id_valid( $id ) };

    # Validate or die.
    if ( my $e = Exception::Class->caught( "E::InvalidID" ) ) {
        # Throw if fail.
        $id = get_id( $id );

        assert( _is_id_valid( $id ) )
            if DEBUG;
    }

    warn "--- Starting get_raw( $id ).\n"
        if $IS_RIOT;

    # UserAgent can not place outer, cause I can not clear cookies.
    my $ua = LWP::UserAgent->new;

    my( $cookie_jar, $title ) = _get_cookies_and_title( $ua, $id );
    assert( defined $cookie_jar and defined $title )
        if DEBUG;

    $ua->cookie_jar( $cookie_jar );

    my $url = $SOUND_URL . $id . ".mp3";

    my $res = $ua->get( $url );

    if ( $res->is_error ) {
        E::DownloadError->throw(
            message     => "Could not get MP3 data.",
            status_line => $res->status_line,
        );
    }
    assert( defined $res->content )
        if DEBUG;

### TODO: Overworking.
    if ( bytes::length( $res->content ) < $MIN_SIZE ) {
        if ( 1 ) { # Overworking.
            E::Overworking->throw(
                message => "The NicoSound is overworking, try later.",
                id      => $id,
            );
        }
    }

    warn "--- Got raw MP3 data.\n"
        if $IS_RIOT;

    return \$res->content;
}

sub _get_cookies_and_title {
    assert( @_ == 2 )
        if DEBUG;

    my $ua = shift;
    my $id = shift;
    assert( defined $ua )
        if DEBUG;
    assert( defined $id )
        if DEBUG;
    assert( _is_id_valid( $id ) )
        if DEBUG;

    # Pre-GET for save MP3.
    my $url = $INFO_URL . $id;
    my $res = $ua->get( $url );

    if ( $res->is_error ) {
        E::DownloadError->throw(
            message     => "Failed pre GET that needs for get MP3.",
            status_line => $res->status_line,
        );
    }

    warn "--- Succeeded first GET.\n"
        if $IS_RIOT;

    # Can not get MP3 cause NicoSound web service.
    if ( $res->content =~ m{ video_deleted [.] jpg }imsx ) {
        E::HasBeenDeleted->throw(
            message => "The ID has been deleted.",
            id      => $id,
        );
    }

    # Parse HTML.
    my $dom = HTML::DOM->new;
    $dom->write( $res->decoded_content );
    $dom->close;

    # Get title for filename.
    my $title = $dom->getElementsByTagName( "title" )->[0]->text;
    $title =~ s{\A \s*}{}msx;
    $title =~ s{\s* \z}{}msx;
    my $hosi = "☆";
    my $nico = "にこ".$hosi."さうんど＃";
    $title =~ s{[ ][-][ ]$nico .*}{}msx;
    $title =~ s{ [/] }{／}gmsx;

    # Did get title?
    unless ( $title ) {
        E::DownloadError->throw(
            message     => "Could not parse title from HTML.",
            status_line => undef,
        );
    }

    warn "--- Title is [$title].\n"
        if $IS_RIOT;

    # The most important codes for NicoSound web service.
    # Cookies require for obtaining from NicoSound web service.
    # The flow of obtaining is:
    #   - GET  http://nicosound.anyap.info/sound/sm0000000
    #   - POST http://nicosound.anyap.info/sound/sm0000000
    #   - GET  http://nicosound2.anyap.info:8080/sound/sm0000000.mp3

    my $element_id = "ctl00_ContentPlaceHolder1_SoundInfo1_btnLocal2";
    my( $post_param ) = grep { $_->id eq $element_id }
                        $dom->getElementsByTagName( "a" );

    # Does defined POST parameter?
    unless ( defined $post_param ) {
        E::DownloadError->throw(
            message     => "Could not parse the parameters for POST.",
            status_line => undef,
        );
    }

    my( $event_target, $event_argument )
        = $post_param->href =~ m{ __doPostBack [(] ['] ([^']+) ['] [,] ['] ([^']*) }msx;

    # Does defined event target?
    unless ( ( defined $event_target ) and ( defined $event_argument ) ) {
        E::DownloadError->throw(
            message     => "Could not parse the parameters for POST.",
            status_line => undef,
        );
    }

#    my $cookie_jar = HTTP::Cookies->new( { } );
    my $cookie_jar = HTTP::Cookies->new;

    $res = $ua->post(
        $INFO_URL . $id,
        {
            __EVENTTARGET   => $event_target,
            __EVENTARGUMENT => $event_argument,
        },
    );
    assert( $res->status_line =~ m{302} )
        if DEBUG;

    warn "--- Succeeded the POST.\n"
        if $IS_RIOT;

    $cookie_jar->extract_cookies( $res );
    assert( defined $cookie_jar )
        if DEBUG;

    return ( $cookie_jar, $title );
}

=item save_mp3( "nm0000000" )

This function preserves MP3 data to a file.
And returns filename that was preserved.

Second parameter is filename.
If it is not defined, this function tries to get original name.
If could not, preserve as "<process ID>.<number>.mp3",
but this case is odd.
This naming function is use to saving data from some fatal error.
Do not try next ID.

=cut

sub save_mp3 {
    unless ( @_ ) {
        E::IDRequired->throw(
            message => "ID Required.",
        );
    }

    my ( $id, $filename ) = @_;

    # Is ID valid?
    eval { _is_id_valid( $id ) };

    # Validate or die.
    if ( my $e = Exception::Class->caught( "E::InvalidID" ) ) {
        # Throw if fail.
        $id = get_id( $id );

        assert( _is_id_valid( $id ) )
            if DEBUG;
    }

    # Does file already exist?
    if ( defined $filename and -e $filename ) {
        E::FileAlreadyExists->throw(
            message  => "The file already exists.",
            filename => $filename,
        );
    }

    my $ua = LWP::UserAgent->new;

    my( $cookie_jar, $title ) = _get_cookies_and_title( $ua, $id );
    assert( defined $cookie_jar )
        if DEBUG;
    assert( defined $title )
        if DEBUG;

    if ( not defined $filename ) {
        $filename = _validate_filename( $title );

        if ( -e $filename ) {
            E::FileAlreadyExists->throw(
                message  => "The file already exists.",
                filename => $filename,
            );
        }
    }
    assert( defined $filename )
        if DEBUG;
    assert( not -e $filename )
        if DEBUG;

    $ua->cookie_jar( $cookie_jar );

    my $url = $SOUND_URL . $id . ".mp3";

    warn "--- Starting save_mp3[$filename].\n"
        if $IS_RIOT;

    my $res = $ua->get(
        $url,
        ":content_file" => $filename,
    );

    if ( $res->is_error ) {
        E::DownloadError->throw(
            message     => "Could not get MP3 data.",
            status_line => $res->status_line,
        );
    }
    assert( -f $filename )
        if DEBUG;

    # I hope the NicoSound server returns failure-code of HTTP-status.
    # Now, the server does not return failure code,
    # but returns HTML that the failure withers.
    if ( -T $filename or -s $filename < $MIN_SIZE ) {
        unlink $filename
            or E::CantSave->throw(
                message => "The NicoSound server is overworking.\n"
                         . "Because of this, the downloaded file is not MP3 data.\n"
                         . "So I tried deleting, but it has failed.\n"
                         . "Please delete the file[$filename].",
               );

        E::Overworking->throw(
            message => "The NicoSound server is overworking.\n"
                     . "### Try downloading later.",
            id      => $id,
        );
    }

    return $filename;
}

sub _validate_filename {
    assert( @_ )
        if DEBUG;

    my $filename = join "_", splitdir( shift );

    if ( $filename !~ m{ [.] mp3 \z}imsx ) {
        $filename .= ".mp3";
    }

    return $filename;
}

=back

=head1 SEE ALSO

WWW::NicoSound::Download::Error

=head1 AUTHOR

Kuniyoshi Kouji, E<lt>kuniyoshi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kuniyoshi Kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

