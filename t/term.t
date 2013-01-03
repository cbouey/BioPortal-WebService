use Test::Spec;
use FindBin qw/$Bin/;
use JSON qw/decode_json/;
use File::Slurp;
use File::Spec::Functions;
use BioPortal::Term;

describe 'An ontology term' => sub {
    my ( $json, $hash, $term );

    before all => sub {
        $json = read_file( catfile( $Bin, 'data', 'urea.json' ) );
        $hash = decode_json($json);
        $term = BioPortal::Term->new(
            raw_hash_content => $hash->{success}->{data}->[0]->{classBean} );
    };
    it 'should be an instance of BioPortal::Term' => sub {
        isa_ok( $term, 'BioPortal::Term' );
    };
    it 'should return the correct identifier' => sub {
        is( $term->identifier, 'GO:0000050' );
    };
    it 'should return the correct term name' => sub {
        is( $term->name, 'urea cycle' );
    };
    it 'should not be an obsolete term' => sub {
        is( $term->is_obsolete, 0 );
    };
    it 'should match the term definition' => sub {
        like( $term->definition, qr/urea/ );
    };
    it 'should have three synonyms' => sub {
        is( scalar $term->get_synonyms, 3 );
    };
    describe 'with dbxrefs' => sub {
        my @dbxrefs;
        before all => sub {
            @dbxrefs = $term->get_dbxrefs;
        };
        it 'should have twenty two dbxrefs' => sub {
            is( scalar @dbxrefs, 22 );
        };
        it 'should return an instance of BioPortal::Term::Dbxref' => sub {
            isa_ok( $dbxrefs[0], 'BioPortal::Term::Dbxref' );
        };
        it 'should return a database name' =>
            sub { like( $dbxrefs[0]->database, qr/\S+/ ) };
        it 'should return a database identifier' =>
            sub { like( $dbxrefs[0]->id, qr/\S+/ ) };
    };
    it 'should have two secondary terms' => sub {
        is( scalar $term->get_secondary_ids, 2 );
    };
};

describe 'An ontology term thioredoxin' => sub {
    my ( $json, $hash, $term );

    before all => sub {
        $json = read_file( catfile( $Bin, 'data', 'thioredoxin.json' ) );
        $hash = decode_json($json);
        $term = BioPortal::Term->new(
            raw_hash_content => $hash->{success}->{data}->[0]->{classBean} );
    };

    it 'should be an obsolete term' => sub {
        is( $term->is_obsolete, 1 );
    };

    it 'should have one secondary term' => sub {
        is( scalar $term->get_secondary_ids, 1 );
    };

    it 'should have a comment section' => sub {
        like( $term->comment, qr/\S+/ );
    };
};

runtests unless caller;
