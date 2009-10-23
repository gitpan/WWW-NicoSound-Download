package WWW::NicoSound::Download;

use strict;
use warnings;
use Carp;
no Carp::Assert;
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::DOM;

require Exporter;

our @ISA         = qw( Exporter );
our %EXPORT_TAGS = ( all => [ qw(
    get_id  get_raw  save_mp3  get_ids
) ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{all} } );
our @EXPORT      = ( );

our $VERSION = "1.01";
our $IS_RIOT = 0;

my $INFO_URL  = "http://nicosound.anyap.info/sound/";
my $SOUND_URL = "http://nicosound2.anyap.info:8080/sound/";
my $ID_LIKE   = "[ns]m \\d{6,7}";
my $MIN_SIZE  = 1_000;  # MP3 file should larger than this.
my $INDEX     = 0;

=head1 NAME

WWW::NicoSound::Download - Get mp3 file from NicoSound web service

=head1 SYNOPSIS

  use WWW::NicoSound::Download qw( get_id save_mp3 get_raw get_ids );
  my $url = "http://nicosound.anyap.info/sm0000000";
  my $id  = get_id( $url )
      or die "Could not get NicoSound's ID.";
  eval { save_mp3( $id ) };  # Using original name.
  die $@ if $@;
  eval { save_mp3( $id, "filename.mp3" ) };  # Specify name.
  die $@ if $@;

  # Use following method if you want to modify MP3 data.
  my $raw_ref = eval { get_raw( $id ) };
  die $@ if $@;
  # ..some modification.

  # Get MP3 from a local-file of web-page.
  my @ids = get_ids( "somepage.html" );
  eval { save_mp3( $_ ) }
      foreach @ids;

  # To see module messages, set flag to true.
  $WWW::NicoSound::Download::IS_RIOT = 1;

=head1 DESCRIPTION

In this module, you can preserve a MP3 file from NicoSound.

NicoSound's URL is "http://nicosound.anyap.info/".

=head2 EXPORT

None by default.

=over

=item get_id( "http://nicosound.anyap.info/sm0000000" )

This function parses URL, and returns NicoSound's ID.

=cut

sub get_id {
    my $url = shift;
    unless ( defined $url ) {
        carp "URL was not found.";
        return;
    }

    if ( $url =~ m{ ($ID_LIKE) (?:[^\d] | \z) }msx ) {
        my $id = $1;
        assert( _is_id_valid( $id ) )
            if DEBUG;
        return $id;
    }
    else {
        return;
    }
}

sub _is_id_valid {
    assert( @_ )
        if DEBUG;
    my $id = shift;

    if ( not defined $id ) {
        return;
    }
    elsif ( $id =~ m{\A $ID_LIKE \z}msx ) {
        return 1;
    }
    else {
        return;
    }
}

=item get_raw( "nm0000000" )

This function reads the MP3 data to the memory.
It is used to raw modification.
Use save_mp3 if only saving MP3 data.

=cut

sub get_raw {
    croak "### A parameter required.  Can not undef value."
        unless @_;

    my $id = shift;

    # Validate or die.
    if ( not _is_id_valid( $id ) ) {
        my $candidate = get_id( $id );

        if ( _is_id_valid( $candidate ) ) {
            $id = $candidate;
        }
        else {
            croak "### NicoSound's ID required.";
        }
    }

    warn "--- Starting get_raw( $id ).\n"
        if $IS_RIOT;

    # UserAgent can not place outer, cause I can not clear cookies.
    my $ua = LWP::UserAgent->new( );

    my( $cookie_jar, $title ) = _get_cookies_and_title( $ua, $id );
    assert( defined $cookie_jar and defined $title )
        if DEBUG;

    $ua->cookie_jar( $cookie_jar );

    my $url = $SOUND_URL . $id . ".mp3";

    my $res = $ua->get( $url );
    die "Could not get mp3 data.\n[", $res->status_line, "]"
        if $res->is_error;
    assert( defined $res->content )
        if DEBUG;

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

    my $url = $INFO_URL . $id;
    my $res = $ua->get( $url );
    die "### Could not get HTML from [$url].\n[", $res->status_line, "]"
        if $res->is_error;

    warn "--- Succeeded first GET.\n"
        if $IS_RIOT;

    # Can not get MP3 cause NicoSound web service.
    die "### The ID[$id] has be deleted."
        if $res->content =~ m{ video_deleted [.] jpg }imsx;

    my $dom = HTML::DOM->new( );
    $dom->write( $res->decoded_content );

    # Get title for filename.
    my $title = $dom->getElementsByTagName( "title" )->[0]->text;
    $title =~ s{\A \s*}{}msx;
    $title =~ s{\s* \z}{}msx;
    my $hosi = "☆";
    my $nico = "にこ".$hosi."さうんど＃";
    $title =~ s{[ ][-][ ]$nico .*}{}msx;
    $title =~ s{ [/] }{／}gmsx;

    unless ( $title ) {
        warn "Could not get title";
    }
    else {
        warn "--- Title is [$title].\n"
            if $IS_RIOT;
    }

    # The most important codes for NicoSound web service.
    # Cookies require for obtaining from NicoSound web service.
    # The flow of obtaining is:
    #   - GET  http://nicosound.anyap.info/sound/sm0000000
    #   - POST http://nicosound.anyap.info/sound/sm0000000
    #   - GET  http://nicosound2.anyap.info:8080/sound/sm0000000.mp3
    my( $event_target, $event_argument );
    my $element_id = "ctl00_ContentPlaceHolder1_SoundInfo1_btnLocal2";
    my $post_param = $dom->getElementById( $element_id );
    die "### Could not parse the parameters for POST."
        unless defined $post_param;

    if ( $post_param->href =~ m{__doPostBack[(]'([^']+)',\s*'([^']*)'}msx ) {
        ( $event_target, $event_argument )
            = ( $1, $2 );
    }
    die "### Could not parse the parameters for POST."
        unless ( defined $event_target ) and ( defined $event_argument );

    my $cookie_jar = HTTP::Cookies->new( { } );

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
    my ( $id, $filename ) = @_;
    croak "### A parameter required.  Can not be undef value."
        unless defined $id;

    # Validate NicoSound's ID.
    unless ( _is_id_valid( $id ) ) {
        my $candidate = get_id( $id );

        if ( _is_id_valid( $candidate ) ) {
            $id = $candidate;
        }
        else {
            croak "### NicoSound's ID required.";
        }
    }

    croak "### Filename: [$filename] already exists."
        if defined $filename and -e $filename;

    my $ua = LWP::UserAgent->new( );

    my( $cookie_jar, $title ) = _get_cookies_and_title( $ua, $id );
    $title = $title || _make_unique_name( );
    assert( defined $cookie_jar )
        if DEBUG;
    assert( defined $title )
        if DEBUG;

    if ( not defined $filename ) {
        $filename = $title . ".mp3";

        die "### Filename: [$filename] already exists.  This name from NicoSound."
            if -e $filename;
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
    die "### Could not get MP3 data.\n[", $res->status_line, "]"
        if $res->is_error;

    die "### Could not save MP3 as [$filename]."
        unless -f $filename;
    assert( -f $filename )
        if DEBUG;

    # I hope the NicoSound server returns failure-code of HTTP-status.
    # Now, the server does not return failure code,
    # but returns HTML that the failure withers.
    if ( -T $filename or -s $filename < $MIN_SIZE ) {
        unlink $filename
            or die "### The NicoSound server is overworking.\n",
                   "### Because of this, the downloaded file is not MP3 data.\n",
                   "### So I tried deleting, but it has failed.\n",
                   "### Please delete the file.";

        die "### The NicoSound server is overworking.\n",
            "### Try downloading later.";
    }

    return $filename;
}

sub _make_unique_name {
    return join( ".", $0, $$, $INDEX++, "mp3" );
}

=item get_ids( "webpage.html" )

This function obtains some IDs from web page.
Web page is a HTML file that from NicoSound.

=cut

sub get_ids {
    my $filename = shift;
    if ( not defined $filename ) {
        carp "Filename required.";
        return;
    }
    elsif ( ! -f $filename ) {
        carp "File: [$filename] does not exist.";
        return;
    }

    my $dom = HTML::DOM->new( );
    $dom->parse_file( $filename );

    my @elements = $dom->getElementsByTagName( "a" );
    my %links    = map  { ($_, undef) }
                   grep { defined $_ }
                   map  { $_ ? get_id( $_ ) : undef }
                   map  { $_->href }
                   @elements;
#printf "The number of IDs is: [%d].\n", scalar keys %links;
#print join "\n", sort keys %links;

    warn "--- The number of parsed ID is: ", scalar( keys %links ), ".\n"
        if $IS_RIOT;

    return sort keys %links;
}

=back

=head1 SEE ALSO

=head1 AUTHOR

Kuniyoshi Kouji, E<lt>Kuniyoshi.Kouji@indigo.plala.or.jpE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kuniyoshi Kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;

