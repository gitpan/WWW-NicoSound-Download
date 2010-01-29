package WWW::NicoSound::Download::Error;

use utf8;
use strict;
use warnings;
use Exception::Class (
    # The root error class.
    "NicoSoundError" => {
        fields => [ qw( message ) ],
    },

    # Base error class for save_mp3, and get_raw.
    "E::CantSave" => {
        isa    => "NicoSoundError",
        fields => [ qw( message ) ],
    },

    "E::CantFindHomepage" => {
        isa    => "NicoSoundError",
        fields => [ qw( message status_line ) ],
    },

    "E::IDRequired" => {
        isa    => "NicoSoundError",
        fields => [ qw( message ) ],
    },

    "E::URLRequired" => {
        isa    => "NicoSoundError",
        fields => [ qw( message ) ],
    },

    "E::FilenameRequired" => {
        isa    => "NicoSoundError",
        fields => [ qw( message ) ],
    },

    "E::InvalidID" => {
        isa    => "NicoSoundError",
        fields => [ qw( message id ) ],
    },

    "E::InvalidURL" => {
        isa    => "NicoSoundError",
        fields => [ qw( message url ) ],
    },

    "E::InvalidFilename" => {
        isa    => "NicoSoundError",
        fields => [ qw( message filename ) ],
    },

    "E::FileDoesNotExist" => {
        isa    => "NicoSoundError",
        fields => [ qw( message filename ) ],
    },

    "E::DownloadError" => {
        isa    => "E::CantSave",
        fields => [ qw( message status_line ) ],
    },

    "E::HasBeenDeleted" => {
        isa    => "E::CantSave",
        fields => [ qw( message id ) ],
    },

    "E::Overworking" => {
        isa    => "E::CantSave",
        fields => [ qw( message id ) ],
    },

    "E::FileAlreadyExists" => {
        isa    => "E::CantSave",
        fields => [ qw( message filename ) ],
    },
);


1;
__END__
=head1 NAME

WWW::NicoSound::Download::Error - Error class for WWW::NicoSound::Download

=head1 SYNOPSIS

  use WWW::NicoSound::Download::Error;

  sub will_die {
      NicoSoundError->throw( message => "Somethins is wrong." );
  }

  eval { will_die( ) };

  if ( my $e = Exception::Class->caught( "NicoSoundError" ) ) {
      die $e;
  }

=head1 DESCRIPTION

Blah blah blah.

=head2 EXPORT

None by default.

=head1 DIAGNOSTICES

=over

=item NicoSoundError

This is top level class of error. This is root.

This has message field.

=item E::CantSave

This is base error class for save_mp3, and get_raw methods.

This has message field.

=item E::CantFindHomepage

This will be thrown when the environment can not reach to the NicoSound server.

This has message, and status_line fields.

=item E::IDRequired

This will be thrown when a ID parameter required.

This has message field.

=item E::URLRequired

This will be thrown when a URL parameter required.

This has message field.

=item E::FilenameRequired

This will be thrown when a filename parameter required.

This has message field.

=item E::InvalidID

This will be thrown when can not parse ID from URL.

This has message, and id fields.

=item E::InvalidURL

Same as above. This will be thrown when can not parse ID from URL.
This odd errors is because save_mp3 can accept URL.

This has message, and url fields.

=item E::InvalidFilename

This will be thrown when the filename is 0, or "".

This has message, and filename fields.

=item E::FileDoesNotExist

This will be thrown when the specified filename does not exist.

This has message, and filename fields.

=item E::DownloadError

This will be thrown when failed HTTP method of GET, or any.

This has message, and status_line fields.

=item E::HasBeenDeleted

This will be thrown when the ID's file has been deleted by NicoSound user.
Deleted file can not save.

This has message, and id fields.

=item E::Overworking

This will be thrown when the NicoSound server is overworking.
Try later. This often occurs at midnight.

This has message, and id fields.

=item E::FileAlreadyExists

This will be thrown when the file already exists.

This has message, and filename fields.

=back

=head1 SEE ALSO

WWW::NicoSound::Download

=head1 AUTHOR

Kuniyoshi Kouji, E<lt>kuniyoshi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kuniyoshi Kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

