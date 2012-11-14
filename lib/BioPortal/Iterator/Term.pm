package BioPortal::Iterator::Term;

use namespace::autoclean;
use Moose;
use BioPortal::Term;
use Class::Load qw/load_class/;
extends 'BioPortal::Base';

has [qw/ontology_version_id ontology_virtual_id/] => (
    is  => 'rw',
    isa => 'Str'
);

has 'pagesize' => ( is => 'rw', isa => 'Int', default => 10, lazy => 1 );

has 'total_page' => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    builder => '_build_total_page'
);

sub _build_total_page {
    my ($self) = @_;

    #get the data from BioPortal
    my $json = $self->get(
        path           => '/concepts/' . $self->ontology_version_id . '/all',
        apikey         => $self->apikey,
        pagesize       => $self->pagesize,
        pagenum        => 1,
        maxnumchildren => 0
    );
    return $json->{success}->{data}->[0]->{page}->{numPages};
}

has 'last_page' => (
    is        => 'rw',
    isa       => 'Int',
    predicate => 'has_last_page'
);

has 'current_page' => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => 1,
    traits  => [qw/Counter/],
    handles => { inc_current_page => 'inc' }
);

sub next_term {
    my ($self) = @_;

    #check of something is being fetched already
    #and how many pages its gone through
    if ( $self->has_last_page ) {
        return if $self->current_page > $self->last_page;
    }

    #check if data is already present
    if ( $self->members ) {
        return BioPortal::Term->new(
            apikey           => $self->apikey,
            raw_hash_content => $self->get_first_member
        );

    }

    #get the data from BioPortal
    my $json = $self->get(
        path           => '/concepts/' . $self->ontology_version_id . '/all',
        apikey         => $self->apikey,
        pagesize       => $self->pagesize,
        pagenum        => $self->current_page,
        maxnumchildren => 0
    );

    #increment current page
    $self->inc_current_page;

    #set the last page
    $self->last_page( $json->{success}->{data}->[0]->{page}->{numPages} )
        if !$self->has_last_page;
    $self->raw_array_content(
        $json->{success}->{data}->[0]->{page}->{contents}
            ->{classBeanResultList}->{classBean} );

    return BioPortal::Term->new(
        apikey           => $self->apikey,
        raw_hash_content => $self->get_first_member
    );
}

sub slice {
    my ( $self, $start, $end ) = @_;
    load_class 'BioPortal::Iterator::Term';
    my $itr = BioPortal::Iterator::Term->new(
        apikey              => $self->apikey,
        ontology_version_id => $self->ontology_version_id,
        current_page        => $start,
        last_page           => $end
    );
    $itr->ontology_virtual_id( $self->ontology_virtual_id )
        if $self->ontology_virtual_id;
        return $itr;
}

__PACKAGE__->meta->make_immutable;
1;    # Magic true value required at end of module

__END__

=head1 NAME

BioPortal::Iterator::Term - An iterator to traverse all terms of an ontology


=head1 DESCRIPTION

Not to be use directly,  rather it is created by L<BioPortal::Ontology>.
Once created,  use the public B<API> to work with the object.

=head1 INTERFACE 

=head2 next_term

=over

=item Fetches the next term L<BioPortal::Term> from the collection.

=back

=head2 pagesize

=over

=item default pagesize(10) for the iterator

=back

=head2 current_page

=over

=item  The current page of result that has already being fetched

=back

=head2 last_page

=over

=item The last page of result that yet to be fetched. Excepted for an iterator L<slice>,
this will be identical to L<total_page> value.

=back

=head2 total_page

=over

=item The total page of results that are available from resource. It is read only and
depends on the value of L<pagesize>. The value of L<total_page> and L<last_page> varies in
case of sliced iterator.

=back

=head2 slice
