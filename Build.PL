
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Perl API for accessing ontologies from NCBO bioportal",
  "dist_author" => [
    "Siddhartha Basu <biosidd\@gmail.com>"
  ],
  "dist_name" => "BioPortal-WebService",
  "dist_version" => "1.0.0",
  "license" => "perl",
  "module_name" => "BioPortal::WebService",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Date::Manip" => "6.36",
    "DateTime::Format::Strptime" => "1.52",
    "JSON" => "2.53",
    "LWP::UserAgent" => "6.04",
    "List::MoreUtils" => "0.33",
    "Moose" => "2.0604",
    "OBO::Core::Ontology" => "1.40",
    "namespace::autoclean" => "0.13"
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
