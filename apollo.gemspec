# -*- encoding: utf-8 -*-

# Read the current version
version = File.read('VERSION')

Gem::Specification.new do |s|
  s.name = %q{apollo}
  s.version = version

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Travis D. Warlick, Jr.", "Charlie Savage", "Blake Chambers"]
  s.date = %q{2010-06-17}
  s.email = ["warlickt@operissystems.com", "cfis@zerista.com", "chambb1@gmail.com"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG.md",
     "LICENSE",
     "MIT-LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "apollo.gemspec",
     "lib/apollo.rb",
     "lib/apollo/active_record_extensions.rb",
     "lib/apollo/event.rb",
     "lib/apollo/specification.rb",
     "lib/apollo/state.rb",
     "lib/apollo/state_set.rb",
     "test/couchtiny_example.rb",
     "test/main_test.rb",
     "test/readme_example.rb",
     "test/test_helper.rb",
     "test/without_active_record_test.rb"
  ]
  s.homepage = %q{http://github.com/tekwiz/apollo}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A fork of workflow: a finite-state-machine-inspired API for modeling and interacting with what we tend to refer to as 'workflow'.}
  s.test_files = [
    "test/couchtiny_example.rb",
     "test/main_test.rb",
     "test/readme_example.rb",
     "test/test_helper.rb",
     "test/without_active_record_test.rb"
  ]
end