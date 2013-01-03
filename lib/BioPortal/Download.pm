package BioPortal::Download;
{
    $BioPortal::Download::VERSION = '1.0.0';
}

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
has 'is_obo_format' => (
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

__END__

=pod

=head1 NAME

BioPortal::Download

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
