use Test::Spec;
use BioPortal::WebService;
use File::Temp qw/tempfile/;
use OBO::Parser::OBOParser;
use Test::File;

SKIP: {
    if ( not defined $ENV{BIOPORTAL_API_KEY} ) {
        skip "environmental variable BIOPORTAL_API_KEY is not defined", 3;
    }

    describe 'A bioportal webservice' => sub {
        my $bioportal;
        before all => sub {
            $bioportal = BioPortal::WebService->new(
                apikey => $ENV{BIOPORTAL_API_KEY} );
        };

        it 'should have an instance of BioPortal::WebService' => sub {
            isa_ok( $bioportal, 'BioPortal::WebService' );
        };

        it 'should retreive the specified ontology' => sub {
            my $onto = $bioportal->get_ontology('MI');
            isa_ok( $onto, 'BioPortal::Ontology' );
            is( $onto->identifier, 'MI' );
        };
    };

    describe 'A bioportal webservice downloader' => sub {
        my $bioportal;
        before all => sub {
            $bioportal = BioPortal::WebService->new(
                apikey => $ENV{BIOPORTAL_API_KEY} );
        };

        it 'should fetch a downloader object with a non-empty file' => sub {
            my $download = $bioportal->download('CBO');
            isa_ok( $download, 'BioPortal::Download' );
            isnt( $download->is_obo_format, 1 );
            file_exists_ok( $download->filename );
            file_not_empty_ok( $download->filename );
        };

        it 'should parse the downloaded obo file' => sub {
            my $download = $bioportal->download('ECO');
            file_exists_ok( $download->filename );
            is( $download->is_obo_format, 1 );
            my $obo
                = OBO::Parser::OBOParser->new->work( $download->filename );
            is( $obo->has_term( $obo->get_term_by_name('author statement') ),
                1 );
        };
    };

    runtests unless caller;
}

