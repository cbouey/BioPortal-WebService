use Test::Spec;
use FindBin qw/$Bin/;
use JSON qw/decode_json/;
use File::Slurp;
use File::Spec::Functions;
use BioPortal::Ontology;
use Test::Moose;

describe 'An ontology' => sub {
    my ( $json, $hash, $onto );

    before all => sub {
        $json = read_file( catfile( $Bin, 'data', 'go.json' ) );
        $hash = decode_json($json);
        $onto = BioPortal::Ontology->new(
            raw_hash_content => $hash->{success}->{data}->[0]->{ontologyBean},
            apikey           => 'apikey'
        );
    };
    it 'should be an instance of BioPortal::Ontology' => sub {
        isa_ok( $onto, 'BioPortal::Ontology' );
    };

    it 'should have an ontology id' => sub {
        is( $onto->id, 49457 );
    };

    it 'should have ontology version' => sub {
        is( $onto->data_version, "2012-11-10" );
        is( $onto->version,      "2012-11-10" );
    };

    it 'should have an authority' => sub {
        is( $onto->authority, 'Gene Ontology' );
    };

    it 'should have a definition' => sub {
        like( $onto->definition, qr/^.+?$/ );
    };

    it 'should have a namespace' => sub {
        is( $onto->default_namespace, 'GO' );
        is( $onto->identifier,        'GO' );
    };

    it 'should have a name' => sub {
        is( $onto->name, 'Gene Ontology' );
    };

    it 'should have a release date' => sub {
        my $date = $onto->date;
        isa_ok( $date, 'DateTime' );
        is( $date->year,  2012 );
        is( $date->month, 11 );
        is( $date->day,   11 );
    };

    it 'should return a term iterator' => sub {
        isa_ok( $onto->get_all_terms, 'BioPortal::Iterator::Term' );
    };
};

runtests unless caller;
