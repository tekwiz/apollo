require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rubygems/package_task'

# Set global variable so other tasks can access them
::PROJECT_ROOT = File.expand_path(".")
::GEM_NAME = 'apollo'

# Read the spec file
spec = Gem::Specification.load("#{GEM_NAME}.gemspec")

# Setup Rake tasks for managing the gem
Gem::PackageTask.new(spec).define