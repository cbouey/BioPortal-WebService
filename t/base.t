package PortalTest;
use Moose;
extends 'BioPortal::Base';

__PACKAGE__->meta->make_immutable;
1;

package main;
use Test::Spec;
use Test::Moose;

describe 'A class extending BioPortal::Base' => sub {
    my $portal;
    before all => sub {
        $portal = PortalTest->new;
    };
    it 'should have BioPortal::Base as parent' => sub {
        isa_ok( $portal, 'BioPortal::Base' );
    };
    it 'should have inhertied attributes' => sub {
        has_attribute_ok( $portal, $_ )
            for qw/raw_hash_content
            raw_array_content apikey/;
    };

    it 'should have inherited attributes for http api' => sub {
    	has_attribute_ok($portal, $_) for qw/api_base_url api_format/;
    };

    it 'should have a defined api base url' => sub {
    	like($portal->api_base_url, qr/\S+/);
    };

    it 'should have json as default serialization format' => sub {
    	is($portal->api_format, 'json');
    };

    it 'should have a default useragent object' => sub {
      isa_ok($portal->useragent,  'LWP::UserAgent');
    };

    it 'should have a JSON deserializer' => sub {
    	isa_ok($portal->deserializer,  'JSON');
    };
};


SKIP: {
    if ( not defined $ENV{BIOPORTAL_API_KEY} ) {
        skip "environmental variable BIOPORTAL_API_KEY is not defined",  1;
    }

    describe 'Fetch data from BioPortal' => sub {
    	my $portal;
    	before all => sub {
			$portal = PortalTest->new;
    	};

    	it 'should return a successful response' => sub {
    		my $data = $portal->get(
    			path => '/virtual/ontology/1070', 
    			apikey => $ENV{BIOPORTAL_API_KEY} 
    		);
    		is(defined $data->{success},  1);
    	};
    };
}
runtests unless caller;
