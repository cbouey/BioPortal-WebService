package BioPortal::Term;
use namespace::autoclean;
use Moose;
use List::Util qw/first/;
use Scalar::Util qw/reftype/;
use BioPortal::Term::Dbxref;
extends 'BioPortal::Base';

has 'ontology' => ( is => 'rw', isa => 'BioPortal::Ontology' );

has 'identifier' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->get_content_by_key('id');
    }
);

has 'name' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->get_content_by_key('label');
    }
);

has 'is_obsolete' => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->has_key('isObsolete') ? 1 : 0;
    }
);

has '_raw_meta_content' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    lazy    => 1,
    default => sub { [] },
    handles => { get_all_metadata => 'elements', }
);

has '+raw_hash_content' => (
    trigger => sub {
        my ( $self, $raw_hash ) = @_;
        $self->_raw_meta_content( $raw_hash->{relations}->[0]->{entry} );
    }
);

has 'comment' => (
    is      => 'ro',
    isa     => 'Str|Undef',
    lazy    => 1,
    builder => '_build_comment'
);

sub _build_comment {
    my $self    = shift;
    my $element = first {
        $_->{string} && $_->{string} eq 'Comment';
    }
    $self->get_all_metadata;
    return $element->{list}->[0]->{string} if $element;
}

has 'definition' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $data = $self->get_content_by_key('definitions');
        return $data->[0]->{string};
    }
);

has '_synonyms' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    builder => '_build_synonyms',
    lazy    => 1,
    handles => {
        has_synonym  => 'count',
        get_synonyms => 'elements'
    }
);

sub _build_synonyms {
    my $self     = shift;
    my $synonyms = [];
    for my $item ( grep { $_->{string} =~ /SYNONYM/ }
        $self->get_all_metadata )
    {
        my $syn = $item->{list}->[0]->{string};
        if ( reftype($syn) ) {
            push @$synonyms, @$syn;
        }
        else {
            push @$synonyms, $item;
        }
    }
    return $synonyms;
}

has '_dbxrefs' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    builder => '_build_dbxrefs',
    lazy    => 1,
    handles => {
        has_dbxrefs => 'count',
        get_dbxrefs => 'elements'
    }
);

sub _build_dbxrefs {
    my $self    = shift;
    my $dbxrefs = [];
    for my $item ( grep { $_->{string} eq 'xref' } $self->get_all_metadata ) {
        my $xref = $item->{list}->[0]->{string};
        if ( reftype($xref) ) {
            for my $entry (@$xref) {
                my ( $db, $id ) = split /:/, $entry;
                push @$dbxrefs,
                    BioPortal::Term::Dbxref->new(
                    database => $db,
                    id       => $id
                    );
            }
        }
        else {
            my ( $db, $id ) = split /:/, $item;
            push @$dbxrefs,
                BioPortal::Term::Dbxref->new( database => $db, id => $id );
        }
    }
    return $dbxrefs;
}

has '_secondary' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    builder => '_build_secondary',
    lazy    => 1,
    handles => {
        has_secondary_ids => 'count',
        get_secondary_ids => 'elements'
    }
);

sub _build_secondary {
    my $self   = shift;
    my $altids = [];
    for my $item ( grep { $_->{string} eq 'alt_id' } $self->get_all_metadata )
    {
        my $id = $item->{list}->[0]->{string};
        if ( reftype($id) ) {
            push @$altids, @$id;
        }
        else {
            push @$altids, $id;
        }
    }
    return $altids;
}

__PACKAGE__->meta->make_immutable;

1;    # Magic true value required at end of module

__END__

=head1 NAME

BioPortal::Term - An read only ontology term

=head1 DESCRIPTION

Not to be use directly, rather created from L<BioPortal::Ontology>.
Check the api for using the object.


=head1 INTERFACE 

=head2 ontology

=over

=item Returns L<BioPortal::Ontology> object

=back


=head2 name

=over

=item Term name

=back


=head2 is_obsolete

=over

=item Returns true or false whether the term is retired

=back


=head2 comment

=over

=item Comment about the term,  empty if absent

=back


=head2 definition

=over

=item Definition of term

=back


=head2 get_synonyms

=over

=item Gets list of synonyms

=back

=head2 get_dbxrefs

=over

=item Gets list of L<BioPortal::Dbxref> objects

=back


=head2 get_secondary_ids

=over

=item Gets list of secondary ids

=back

