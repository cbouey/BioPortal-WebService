package BioPortal::WebService;
use namespace::autoclean;
use Moose;
use List::MoreUtils qw/first_index/;
use BioPortal::Ontology;
use Carp;
use File::Temp qw/tempfile/;
use autodie qw/:file/;
extends 'BioPortal::Base';

sub _get_onto_content {
	my ($self, $name) = @_;

    my $content
        = $self->get( path => '/ontologies', apikey => $self->apikey );
    $self->raw_array_content(
        $content->{success}->{data}->[0]->{list}->[0]->{ontologyBean} );
    my $index
        = first_index { $_->{abbreviation} eq $name } $self->all_content;
    if ( !$index ) {
        croak "ontology $name not found\n";
    }
    return $self->get_content_by_index($index);
}

sub download {
    my ( $self, $name, $file ) = @_;
    #get the ontology id
    my $content = $self->_get_onto_content($name);
    my $id           = $content->{ontologyId};

    #download using ontology id
    my $output;
    if ($file) {
        $output = IO::File->new( $file, 'w' );
    }
    else {
        ( $output, $file ) = tempfile();
    }
    my $ua = $self->ua;
    $ua->add_handler(
        response_data => sub {
            my ( $res, $ua, $header, $data ) = @_;
            if ( $res->is_error ) {
                say "!!!! error in fetching";
                die sprintf( "%s\t%s\n", $resp->code, $resp->status_line );
            }
            $output->print($data);
            return $res->is_success;
        }
    );
    $ua->get( $self->api_base_url
            . "/virtual/download/$id?apikey="
            . $self->apikey );
    return $file;
}

sub get_ontology {
    my ( $self, $name ) = @_;
    return BioPortal::Ontology->new(
        raw_hash_content => $self->_get_onto_content($name),
        apikey           => $self->apikey
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

=head2 Download ontology

   use OBO::Parser::OBOParser;

   my $portal = BioPortal::WebService->new(api_key => $apikey);
   my $input = $portal->download('GO');

   my $ontology = OBO::Parser::OBOParser->new->work($input);
   my @terms = $ontology->get_terms;

    

=head1 INTERFACE

=head2 get_ontology

=over

=item Retrieves an ontology by name,  and returns a L<BioPortal::Ontology> object

=back

=head2 download

=over

=item Download an ontology in OBO format

     my $tmpfile = $webservice->download('GO')

Returns a temporary filename or saves output to a given file.

     $webservice->download('GO', 'go.obo');


=back

=head2 More documentation

For rest of the B<API> look at 

=over 

=item L<BioPortal::Base>

=item L<BioPortal::Ontology>

=item L<BioPortal::Term>

=item L<BioPortal::Iterator::Term>

=back

