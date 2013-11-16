require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "architecture-js"
  gem.homepage = "https://github.com/daytonn/architecture-js"
  gem.license = "MIT"
  gem.summary = %Q{architecture.js is a command line application to dynamically build and manage complex javascript applications.}
  gem.description = %Q{Architecture.js helps you generate scaffolding, manage third-party packages, compile, and compress your application.}
  gem.email = "daytonn@gmail.com"
  gem.authors = ["Dayton Nolan"]
  gem.add_runtime_dependency 'jsmin'
  gem.add_runtime_dependency 'listen'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "architecture-js #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
