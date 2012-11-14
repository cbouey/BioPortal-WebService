use Test::Spec;
use FindBin qw/$Bin/;
use JSON qw/decode_json/;
use File::Slurp;
use File::Spec::Functions;
use BioPortal::Iterator::Term;
use Test::Moose;

describe 'A term iterator' => sub {
    my ( $json, $hash, $term, $itr );

    before all => sub {
        $json = read_file( catfile( $Bin, 'data', 'terms.json' ) );
        $hash = decode_json($json);
        $itr  = BioPortal::Iterator::Term->new(
            raw_array_content =>
                $hash->{success}->{data}->[0]->{page}->{contents}
                ->{classBeanResultList}->{classBean},
            apikey => 'apikey',
        );
    };
    it 'should be an instance of BioPortal::Iterator::Term' => sub {
        isa_ok( $itr, 'BioPortal::Iterator::Term' );
    };

    it 'should have ontology_version_id attribute' => sub {
        has_attribute_ok( $itr, 'ontology_version_id' );
    };

    it 'should have ontology_virtual_id attribute' => sub {
        has_attribute_ok( $itr, 'ontology_virtual_id' );
    };

    it 'should have a default pagesize' => sub {
        is( $itr->pagesize, 10 );
    };

    it 'should return a BioPortal::Term object on iteration' => sub {
        isa_ok( $itr->next_term, 'BioPortal::Term' );
        }

};

SKIP: {
    if ( not defined $ENV{BIOPORTAL_API_KEY} ) {
        skip "environmental variable BIOPORTAL_API_KEY is not defined", 3;
    }

    describe 'Fetching live terms from BioPortal' => sub {
        my $itr;
        before all => sub {
            $itr = BioPortal::Iterator::Term->new(
                apikey              => $ENV{BIOPORTAL_API_KEY},
                ontology_version_id => 49136
            );
        };

        it 'should have a defined pages of total results' => sub {
            like( $itr->total_page, qr/^\d+$/ );
        };

        it 'should return a BioPortal::Term' => sub {
            isa_ok( $itr->next_term, 'BioPortal::Term' );
        };

        it 'should have a identical last and total page counts' => sub {
            is( $itr->total_page, $itr->last_page );
        };

        describe 'A slice from the iterator' => sub {
            my $slice_itr;
            before all => sub {
                $slice_itr = $itr->slice( 5, 15 );
            };

            it 'should be a new instance of BioPortal::Iterator::Term' =>
                sub {
                isa_ok( $slice_itr, 'BioPortal::Iterator::Term' );
                };

            it 'should have identical last page and end of slice counts' =>
                sub {
                is( $slice_itr->last_page, 15 );
                };

            it 'should not match last and total page counts' => sub {
                isnt( $slice_itr->last_page, $slice_itr->total_page );
            };

            it 'should match total page count of original iterator' => sub {
                is( $itr->total_page, $slice_itr->total_page );
            };

            it 'should fetch a BioPortal::Term on iteration' => sub {
                isa_ok( $slice_itr->next_term, 'BioPortal::Term' );
            };
        };
    };
}

runtests unless caller;
