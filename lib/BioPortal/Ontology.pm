package BioPortal::Ontology;
{
    $BioPortal::Ontology::VERSION = '1.0.0';
}
use namespace::autoclean;
use Moose;
use DateTime::Format::Strptime;
use BioPortal::Iterator::Term;
extends 'BioPortal::Base';

has 'id' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->get_content_by_key('id');
    }
);

has [ 'data_version', 'version' ] => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->get_content_by_key('versionNumber');
    }
);

has 'authority' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->get_content_by_key('contactName');
    }
);

has 'definition' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->get_content_by_key('description');
    }
);

has [ 'default_namespace', 'identifier' ] => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->get_content_by_key('abbreviation');
    }
);

has 'name' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->get_content_by_key('displayLabel');
    }
);

has 'date' => (
    is      => 'ro',
    isa     => 'DateTime',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $fmt = DateTime::Format::Strptime->new(
            pattern  => '%Y-%m-%d',
            on_error => 'croak'
        );
        return $fmt->parse_datetime(
            $self->get_content_by_key('dateReleased') );
    }
);

sub get_all_terms {
    my ($self) = @_;
    return BioPortal::Iterator::Term->new(
        apikey              => $self->apikey,
        ontology_version_id => $self->id,
        ontology_virtual_id => $self->get_content_by_key('ontologyId')
    );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

BioPortal::Ontology

=head1 VERSION

version 1.0.0

=head1 DESCRIPTION

Not to be use directly,  rather retreived from L<BioPortal::WebService>.
Once retreived use the public B<APIs> listed below.

=head1 NAME

BioPortal::Ontology - An read only ontology retrieved from BioPortal.

=head1 INTERFACE

=head2 data_version/version

=over

=item version of the ontlology

=back

=head2 authority

=over

=item authority/organization who manages the ontology

=back

=head2 definition

=over

=item Description of the ontology

=back

=head2 default_namespace/identifier

=over

=item Default namespace of the ontology,  the one that is being used to retreive it from
the L<BioPortal::WebService>

=back

=head2 name

=over

=item Representative name of the ontology

=back

=head2 date

=over

=item A L<DateTime> object representing the release date

=back

=head2 get_all_terms

=over

=item To iterate over terms,  returns a L<BioPortal::Iterator::Term>

=back

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
