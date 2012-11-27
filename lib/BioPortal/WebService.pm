package BioPortal::WebService;
use namespace::autoclean;
use Carp;
use Moose;
use File::Temp;
use BioPortal::Ontology;
use BioPortal::Download;
use autodie qw/:file/;
use feature qw/say/;
use Scalar::Util qw/reftype/;
use List::MoreUtils qw/first_index firstval/;
use IO::Uncompress::Unzip qw/unzip $UnzipError/;
extends 'BioPortal::Base';

sub _get_onto_content {
    my ( $self, $name ) = @_;

    my $content
        = $self->get( path => '/ontologies', apikey => $self->apikey );
    $self->raw_array_content(
        $content->{success}->{data}->[0]->{list}->[0]->{ontologyBean} );
    my $index
        = first_index { $_->{abbreviation} eq $name } $self->all_content;
    if ( not defined $index ) {
        croak "ontology $name not found\n";
    }
    return $self->get_content_by_index($index);
}

sub download {
    my ( $self, $name ) = @_;

    #get the ontology id
    my $content = $self->_get_onto_content($name);
    my $id      = $content->{ontologyId};

    my $tmpfile = File::Temp->new->filename;
    my $ua      = $self->useragent;
    $ua->get(
        $self->api_base_url . "/virtual/download/$id?apikey=" . $self->apikey,
        ':content_file' => $tmpfile
    );

    #check if its going to be zip file
    if ( $self->_is_zipped_download($content) ) {
        my $filename = File::Temp->new->filename;
        my $status = unzip $tmpfile => $filename
            or croak "unzip failed: $UnzipError\n";
        return BioPortal::Download->new(
            filename => $filename,
            _content => $content
        );
    }
    return BioPortal::Download->new(
        filename => $tmpfile,
        _content => $content
    );
}

sub _is_zipped_download {
    my ( $self, $content ) = @_;
    my $files = $content->{filenames}->[0]->{string};
    if ( reftype $files) {
        return ( firstval {/(obo|owl)$/} @$files ) ? 0 : 1;
    }
    return ( $files =~ /zip$/ ) ? 1 : 0;
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
   my $download = $portal->download('GO');

   if ($download->is_obo) {
     my $ontology = OBO::Parser::OBOParser->new->work($download->filename);
     my @terms = $ontology->get_terms;
   }

    

=head1 INTERFACE

=head2 get_ontology

=over

=item Retrieves an ontology by name,  and returns a L<BioPortal::Ontology> object

=back

=head2 download

=over

=item Download an ontology in OBO format,  gets a L<BioPortal::Download> object 

     my $download = $webservice->download('GO')
     say $download->filename;
     if ($download->is_obo) {
        ...parse obo file here
     }

=back

=head2 More documentation

For rest of the B<API> look at 

=over 

=item L<BioPortal::Base>

=item L<BioPortal::Ontology>

=item L<BioPortal::Term>

=item L<BioPortal::Iterator::Term>

=back

