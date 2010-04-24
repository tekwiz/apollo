require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "apollo"
    gem.summary = %Q{A fork of workflow: a finite-state-machine-inspired API for modeling and interacting with what we tend to refer to as 'workflow'.}
    gem.email = "warlickt@operissystems.com"
    gem.homepage = "http://github.com/tekwiz/apollo"
    gem.authors = ["Travis D. Warlick, Jr."]
    # gem.add_development_dependency "rspec", "~> 1.3.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

# TODO rspecs
# require 'spec/rake/spectask'
# Spec::Rake::SpecTask.new(:spec) do |spec|
#   spec.libs << 'lib' << 'spec'
#   spec.spec_files = FileList['spec/**/*_spec.rb']
# end
# 
# Spec::Rake::SpecTask.new(:rcov) do |spec|
#   spec.libs << 'lib' << 'spec'
#   spec.pattern = 'spec/**/*_spec.rb'
#   spec.rcov = true
#   spec.rcov_opts << '--exclude \/Library\/' << '--exclude /\.gem\/'
# end

# task :spec => :check_dependencies
# 
# task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Apollo #{version}"
  rdoc.rdoc_files.include('README*', 'MIT-LICENSE', 'LICENSE', 'VERSION', 'CHANGELOG.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# task :clobber => [:clobber_rcov, :clobber_rdoc]
