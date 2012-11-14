use Test::Spec;
use BioPortal::WebService;
use Test::More qw/no_plan/;

SKIP: {
    if ( not defined $ENV{BIOPORTAL_API_KEY} ) {
        skip "environmental variable BIOPORTAL_API_KEY is not defined",  3;
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
    runtests unless caller;
}

