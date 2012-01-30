# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "architecture-js"
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dayton Nolan"]
  s.date = "2012-01-30"
  s.description = "Architecture.js helps you generate scaffolding, manage third-party packages, compile, and compress your application."
  s.email = "daytonn@gmail.com"
  s.executables = ["architect"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".DS_Store",
    ".document",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "architecture-js.gemspec",
    "bin/architect",
    "lib/architecture-js.rb",
    "lib/architecture-js/architect.rb",
    "lib/architecture-js/command.rb",
    "lib/architecture-js/dependencies.rb",
    "lib/architecture-js/generator.rb",
    "lib/architecture-js/helpers.rb",
    "lib/architecture-js/notification.rb",
    "lib/architecture-js/project.rb",
    "repository/modjs/plugins/jquery-elements.js",
    "spec/.DS_Store",
    "spec/architecture-js_spec.rb",
    "spec/cli_spec.rb",
    "spec/command_spec.rb",
    "spec/fixtures/.DS_Store",
    "spec/fixtures/compiled_src.js",
    "spec/fixtures/compressed.architecture",
    "spec/fixtures/compressed.js",
    "spec/fixtures/ejs.ejs",
    "spec/fixtures/existing.architecture",
    "spec/fixtures/lib1.js",
    "spec/fixtures/lib2.js",
    "spec/fixtures/myapp.architecture",
    "spec/fixtures/src_file.js",
    "spec/fixtures/templates/test_template_one.js",
    "spec/fixtures/templates/test_template_two.js",
    "spec/fixtures/test_template_options.js",
    "spec/fixtures/test_template_two.js",
    "spec/generator_spec.rb",
    "spec/helpers_spec.rb",
    "spec/notification_spec.rb",
    "spec/project_spec.rb",
    "spec/spec_helper.rb",
    "templates/blank.js"
  ]
  s.homepage = "http://github.com/daytonn/architecture.js"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "architecture.js is a command line application to dynamically build and manage complex javascript applications."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fssm>, ["~> 0.2.8.1"])
      s.add_runtime_dependency(%q<jsmin>, ["~> 1.0.1"])
      s.add_runtime_dependency(%q<sprockets>, ["= 1.0.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<ZenTest>, ["~> 4.6.2"])
      s.add_development_dependency(%q<autotest-growl>, ["~> 0.2.16"])
      s.add_runtime_dependency(%q<jsmin>, [">= 0"])
      s.add_runtime_dependency(%q<fssm>, [">= 0"])
      s.add_runtime_dependency(%q<sprockets>, ["= 1.0.2"])
    else
      s.add_dependency(%q<fssm>, ["~> 0.2.8.1"])
      s.add_dependency(%q<jsmin>, ["~> 1.0.1"])
      s.add_dependency(%q<sprockets>, ["= 1.0.2"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<ZenTest>, ["~> 4.6.2"])
      s.add_dependency(%q<autotest-growl>, ["~> 0.2.16"])
      s.add_dependency(%q<jsmin>, [">= 0"])
      s.add_dependency(%q<fssm>, [">= 0"])
      s.add_dependency(%q<sprockets>, ["= 1.0.2"])
    end
  else
    s.add_dependency(%q<fssm>, ["~> 0.2.8.1"])
    s.add_dependency(%q<jsmin>, ["~> 1.0.1"])
    s.add_dependency(%q<sprockets>, ["= 1.0.2"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<ZenTest>, ["~> 4.6.2"])
    s.add_dependency(%q<autotest-growl>, ["~> 0.2.16"])
    s.add_dependency(%q<jsmin>, [">= 0"])
    s.add_dependency(%q<fssm>, [">= 0"])
    s.add_dependency(%q<sprockets>, ["= 1.0.2"])
  end
end

