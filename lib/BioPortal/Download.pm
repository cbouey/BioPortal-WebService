package BioPortal::Download;

use namespace::autoclean;
use Moose;
use File::Copy;

has '_content' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    lazy    => 1,
    default => sub { {} },
    handles => { '_get_value' => 'get' }
);

has 'filename' => ( is => 'rw', isa => 'Str' );
has 'is_obo' => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $value = $self->_get_value('format');
        return ( $value eq 'OBO' ) ? 1 : 0;
    }
);

sub save_to {
    my ( $self, $to ) = @_;
    copy $self->filename, $to;
}

__PACKAGE__->meta->make_immutable;
1;    # Magic true value required at end of module

