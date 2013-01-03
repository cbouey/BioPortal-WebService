requires "DateTime::Format::Strptime" => "1.52";
requires "JSON" => "2.53";
requires "LWP::UserAgent" => "6.04";
requires "List::MoreUtils" => "0.33";
requires "Moose" => "2.0604";
requires "OBO::Core::Ontology" => "1.40";
requires "namespace::autoclean" => "0.13";

on 'build' => sub {
  requires "Date::Manip" => "6.36";
  requires "Module::Build" => "0.3601";
};

on 'test' => sub {
  requires "Test::File" => "1.34";
  requires "Test::Spec" => "0.46";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
