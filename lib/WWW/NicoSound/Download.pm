package WWW::NicoSound::Download;

use strict;
use warnings;
use Carp;
no Carp::Assert;
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::DOM;

require Exporter;

our @ISA         = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
    get_id  get_raw  save_mp3  get_ids
) ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT      = ( );

our $VERSION = '0.02';
our $IS_RIOT = 0;

my $INFO_URL  = "http://nicosound.anyap.info/sound/";
my $SOUND_URL = "http://nicosound2.anyap.info:8080/sound/";
my $ID_LIKE   = "[ns]m \\d{6,7}";
my $INDEX     = 0;

=head1 NAME

WWW::NicoSound::Download - Get mp3 file from NicoSound

=head1 SYNOPSIS

  use WWW::NicoSound::Download qw( get_id save_mp3 get_raw get_ids );
  my $url = "http://nicosound.anyap.info/sm0000000";
  my $id  = get_id($url);
  save_mp3($id);  # Using original name.
  save_mp3($id, "filename.mp3");  # This uses specified name.

  # Use following method if you want to modify MP3 data.
  my $raw_ref = get_raw($id);
  # ..some modification.

  # Get MP3 from a local-file of web-page.
  my @ids = get_ids("somepage.html");
  save_mp3($_)
      for @ids;

  # To see module messages, set flag to true.
  $WWW::NicoSound::Download = 1;

=head1 DESCRIPTION

In this module, you can preserve a file from NicoSound's mp3.

NicoSound's URL is "http://nicosound.anyap.info/".

=head2 EXPORT

None by default.

=over

=item get_id("http://nicosound.anyap.info/sm0000000")

This function parses URL and returns ID.

=cut

sub get_id {
    my $url = shift;
    unless ($url) {
        carp "URL was not found.";
        return;
    }

    if ($url =~ m{ /($ID_LIKE) (?:[^\d] | \z) }msx) {
        my $id = $1;
        assert( _is_id_valid($id) )
            if DEBUG;
        return $id;
    }
    else {
        return;
    }
}

sub _is_id_valid {
    my $id = shift;
    assert( defined $id )
        if DEBUG;

    return 1
        if ($id =~ m{\A $ID_LIKE \z}msx);
    return;
}

=item get_raw("nm0000000")

This function reads the MP3 data to the memory.
It is used to raw modification.
Use save_mp3 if only saving MP3 data.

=cut

sub get_raw {
    my $id = shift;
    if (not defined $id) {
        carp "NicoSound ID was not found.";
        return;
    }
    elsif (not _is_id_valid($id)) {
        carp "NicoSound ID is invalid.";
        return;
    }

    warn "Starting get_raw($id).\n"
        if $IS_RIOT;

    # UserAgent can not place outer, cause I can not clear cookies.
    my $ua = LWP::UserAgent->new();

    my ($cookie_jar, $title) = _get_cookies_and_title($ua, $id);
    #if ( (not defined $cookie_jar) or (not defined $title) ) {
    unless ( $cookie_jar ) {
        warn "Could not get cookie or title.\n(id=$id)";
        return;
    }

    $ua->cookie_jar( $cookie_jar );

    my $url = $SOUND_URL . $id . ".mp3";

    my $res = $ua->get($url);
    unless ( $res->is_success() ) {
        warn "Could not get mp3 data.\n(", $res->status_line(), ")";
        return;
    }
    assert( defined $res->content() )
        if DEBUG;

    warn "Got raw MP3 data.\n"
        if $IS_RIOT;

    return \$res->content();
}

sub _get_cookies_and_title {
    my $ua = shift;
    assert( defined $ua )
        if DEBUG;
    my $id = shift;
    assert( defined $id )
        if DEBUG;
    assert( _is_id_valid($id) )
        if DEBUG;

    my $url = $INFO_URL . $id;
    my $res = $ua->get($url);

    if(not $res->is_success()) {
        warn "Could not get HTML from ($url).\n(", $res->status_line(), ")";
        return;
    }
    warn "Success first GET.  And try POST.\n"
        if $IS_RIOT;

    my $dom = HTML::DOM->new();
    $dom->write( $res->content() );

    my $title = $dom->getElementsByTagName("title")->[0]->text();
    utf8::decode($title);
    $title =~ s{\A \s*}{}msx;
    $title =~ s{\s* \z}{}msx;
    my $hosi = "☆";
    my $nico = "にこ".$hosi."さうんど＃";
    $title =~ s{[ ][-][ ]$nico .*}{}msx;
    $title =~ s{ [/] }{／}gmsx;
    if (DEBUG) {
        my @elements = $dom->getElementsByTagName("meta");
        @elements = grep { $_->getAttribute("content") =~ m{charset}msx }
                    @elements;
        assert( $elements[-1]->getAttribute("content") =~ m{charset=utf-8}msx );
    }
    unless( $title ) {
        warn "Could not get title";
    }
    else {
        warn "Title is ($title).\n"
            if $IS_RIOT;
    }

    my ($event_target, $event_argument);
    my $element_id = "ctl00_ContentPlaceHolder1_SoundInfo1_btnLocal2";
    my $post_param = $dom->getElementById($element_id);
    unless (defined $post_param) {
        warn "Could not parse the parameters for POST.";
        return;
    }

    if ($post_param->href() =~ m{__doPostBack[(]'([^']+)',\s*'([^']*)'}msx) {
        ($event_target, $event_argument)
            = ($1, $2);
    }
    assert( (defined $event_target) and (defined $event_argument) )
        if DEBUG;

    my $cookie_jar = HTTP::Cookies->new({});

    $res = $ua->post(
        $INFO_URL . $id,
        {
            __EVENTTARGET   => $event_target,
            __EVENTARGUMENT => $event_argument,
        },
    );
    assert( $res->status_line() =~ m{302} )
        if DEBUG;
    warn "Succeeded the POST.\n"
        if $IS_RIOT;

    $cookie_jar->extract_cookies($res);
    assert( defined $cookie_jar )
        if DEBUG;

    return ($cookie_jar, $title);
}

=item save_mp3("nm0000000")

This function preserves MP3 data to filename.
And returns filename that was preserved.

Second parameter is filename.
If it is not defined, this function try to get original name.
But could not, preserve as "<process ID>.<number>.mp3".

=cut

sub save_mp3 {
    my ($id, $filename) = @_;
    if (not defined $id) {
        carp "Nico ID was not found.";
        return;
    }
    elsif (not _is_id_valid($id)) {
        carp "Nico ID is invalid.";
        return;
    }

    if (defined $filename and -e $filename) {
        carp "Filename: ($filename) already exists.";
        return;
    }

    my $ua = LWP::UserAgent->new();

    my ($cookie_jar, $title) = _get_cookies_and_title($ua, $id);
    $title = $title || _make_unique_name();
    assert( defined $cookie_jar )
        if DEBUG;
    assert( defined $title )
        if DEBUG;

    if (not defined $filename) {
        $filename = $title . ".mp3";

        if (-e $filename) {
            carp "Filename: ($filename) already exists.  This name from NicoSound";
            return;
        }
    }
    assert( defined $filename )
        if DEBUG;
    assert( not -e $filename )
        if DEBUG;

    $ua->cookie_jar( $cookie_jar );

    my $url = $SOUND_URL . $id . ".mp3";

    warn "Starting save_mp3($filename).\n"
        if $IS_RIOT;

    my $res = $ua->get(
        $url,
        ":content_file" => $filename,
    );
    if (not $res->is_success()) {
        warn "Could not get MP3 data.\n".$res->status_line();
        return;
    }
    assert( defined $res->content() )
        if DEBUG;
    if (not -f $filename) {
        warn "Could not save MP3 as [filename: ($filename)].";
        return;
    }
    assert( -f $filename )
        if DEBUG;

    return $filename;
}

sub _make_unique_name {
    return join(".", $0, $$, $INDEX++, "mp3");
}

=item get_ids("webpage.html")

This function obtains some ID from web page.
Web page is a HTML file that from NicoSound.

=cut

sub get_ids {
    my $filename = shift;
    if (not defined $filename) {
        carp "Filename was not found.";
        return;
    }
    elsif (!-f $filename) {
        carp "File: ($filename) do not exists.";
        return;
    }

    my $dom = HTML::DOM->new();
    $dom->parse_file($filename);

    my @elements = $dom->getElementsByTagName("a");
    my %links    = map  { ($_, undef) }
                   grep { defined $_ }
                   map  { $_ ? get_id($_) : undef }
                   map  { $_->href() }
                   @elements;
#printf "The number of IDs is: (%d).\n", scalar keys %links;
#print join "\n", sort keys %links;

    warn "The number of parsed ID is: ", scalar(keys %links), ".\n"
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

