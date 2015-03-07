require 'rdoc/task'
require 'rspec/core/rake_task'
require File.expand_path(File.dirname(__FILE__) + '/lib/icu_utils/version')

task :default => :spec

version = ICU::Utils::VERSION

desc "Build a new gem for version #{version}"
task :build do
  system "gem build icu_utils.gemspec"
  system "mv {,pkg/}icu_utils-#{version}.gem"
end

desc "Release gem version #{version} to rubygems.org"
task :release => :build do
  system "gem push pkg/icu_utils-#{version}.gem"
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--colour --format doc']
end

RDoc::Task.new do |rdoc|
  rdoc.title = "ICU Utils #{version}"
  rdoc.main  = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end
