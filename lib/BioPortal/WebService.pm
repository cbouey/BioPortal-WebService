package BioPortal::WebService;
use namespace::autoclean;
use Moose;
use List::MoreUtils qw/first_index/;
use BioPortal::Ontology;
use Carp;
extends 'BioPortal::Base';


sub get_ontology {
    my ( $self, $name ) = @_;
    my $content
        = $self->get( path => '/ontologies', apikey => $self->apikey );
    $self->raw_array_content(
        $content->{success}->{data}->[0]->{list}->[0]->{ontologyBean} );
    my $index
        = first_index { $_->{abbreviation} eq $name } $self->all_content;
    if ( !$index ) {
        croak "ontology $name not found\n";
    }
    my $onto_content = $self->get_content_by_index($index);
    return BioPortal::Ontology->new(
        raw_hash_content => $onto_content,
        apikey          => $self->apikey
    );
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

BioPortal::WebService - Perl API for accessing ontologies from NCBO bioportal

=head1 USAGE

First get an apikey from L<NCBO BioPortal|http://bioportal.bioontology.org>

=head2 Get an ontology

   use BioPortal::WebService;

   my $portal = BioPortal::WebService->new(api_key => $apikey);
   my $ontology = $portal->get_ontology('GO');
   say $ontology->name;

=head2 Iterate and get individual terms

     my $itr = ontology->get_all_terms;
     while(my $term = $itr->next_term) {
        say sprintf "%s\t%s\t%s", $term->name, $term->definition, $term->identifier;
     }

    

=head1 INTERFACE

=head2 get_ontology

=over

=item Retrieves an ontology by name,  and returns a L<BioPortal::Ontology> object

=back

=head2 For rest of the B<API> look at 

=over 

=item L<BioPortal::Base>

=item L<BioPortal::Ontology>

=item L<BioPortal::Term>

=item L<BioPortal::Iterator::Term>

=back


