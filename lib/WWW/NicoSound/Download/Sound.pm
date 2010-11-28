package WWW::NicoSound::Download::Sound;

use utf8;
use strict;
use warnings;
use Carp qw( croak );
use Readonly;
use base "Class::Accessor";
use File::Spec::Functions qw( splitdir );

Readonly my $INFO_URL  => "http://nicosound.anyap.info/sound/";
#Readonly my $SOUND_URL => "http://nicosound2.anyap.info:8080/sound/";
Readonly my $SOUND_URL => "http://ns1.anyap.info:8080/sound/";
Readonly my $ID_LIKE   => "([ns]m|zb|so) \\d{6,8}";

__PACKAGE__->mk_accessors(
    qw( url  id  title  filename ),
);

#
# Class methods.
#

sub new {
    my $class = shift;
    my %param = @_;
    my $self  = bless { }, $class;

    if ( exists $param{id} ) {
        die sprintf "Invalid ID[%s].", $param{id}
            unless $class->is_id_valid( $param{id} );

        $self->id( $param{id} );
    }
    elsif ( exists $param{url} ) {
        $self->url( $param{url} );
        $self->parse_id_from_url;
    }

    if ( exists $param{filename} ) {
        $self->filename( $param{filename} );
    }

    return $self;
}

sub is_id_valid {
    my $class = shift;
    my $id    = shift;

    die "ID required.",
        unless defined $id;

    return $id
        if $id =~ m{\A $ID_LIKE \z}msx;

    die sprintf "ID[%s] is invalid.", $id;
}

#
# Instance methods.
#

sub info_url {
    my $self = shift;

    return $INFO_URL . $self->id;
}

sub sound_url {
    my $self = shift;

    return $SOUND_URL . $self->id . ".mp3";
}

sub parse_id_from_url {
    my $self = shift;

    croak "URL required."
        unless defined $self->url;

    my $id = do {
        if ( $self->url =~ m{ ($ID_LIKE) (?:[^\d] | \z) }msx ) {
            my $candidate = $1;

            __PACKAGE__->is_id_valid( $candidate );

            $candidate;
        }
        else {
            die sprintf "URL[%s] is invalid.", $self->url;
        }
    };

    $self->id( $id );

    return $self;
}

sub parse_filename_from_title {
    my $self = shift;

    croak "Title required."
        unless $self->title;

    my $filename = join "_", splitdir( $self->title );

    if ( $filename !~ m{ [.] mp3 \z}imsx ) {
        $filename .= ".mp3";
    }

    $self->filename( $filename );

    return $self;
}

1;

__END__
=encoding utf-8

=head1 NAME

WWW::NicoSound::Download::Sound - A property class of MP3 file.

=head1 SYNOPSIS

  my $sound = $downloader->save( url => $url );
  say $sound->filename;

=head1 DESCRIPTION

This class keeps information of result of WWW::NicoSound::Download's downloader.

=head1 CLASS METHODS

=over

=item new

Returns new instance of this class.

=item is_id_valid

Checks the parameter likes nicosound ID.

=back

=head1 INSTANCE METHODS

=over

=item info_url

=item sound_url

=item parse_id_from_url

=item parse_filename_from_title

=back

=head1 PROPERTIES

=item url

=item id

=item title

=item filename

=over

=item url

=back

=head1 SEE ALSO

The homepage URL of NicoSound is "http://nicosound.anyap.info/"

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Kuniyoshi Kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

