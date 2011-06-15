# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongoid_ext}
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David A. Cuadrado"]
  s.date = %q{2011-06-14}
  s.default_executable = %q{mongoid_console}
  s.description = %q{mongoid plugins}
  s.email = %q{krawek@gmail.com}
  s.executables = ["mongoid_console"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/mongoid_console",
    "lib/mongoid_ext.rb",
    "lib/mongoid_ext/criteria_ext.rb",
    "lib/mongoid_ext/document_ext.rb",
    "lib/mongoid_ext/file.rb",
    "lib/mongoid_ext/file_list.rb",
    "lib/mongoid_ext/file_server.rb",
    "lib/mongoid_ext/filter.rb",
    "lib/mongoid_ext/filter/parser.rb",
    "lib/mongoid_ext/filter/result_set.rb",
    "lib/mongoid_ext/js/filter.js",
    "lib/mongoid_ext/js/find_tags.js",
    "lib/mongoid_ext/js/tag_cloud.js",
    "lib/mongoid_ext/modifiers.rb",
    "lib/mongoid_ext/mongo_mapper.rb",
    "lib/mongoid_ext/paranoia.rb",
    "lib/mongoid_ext/patches.rb",
    "lib/mongoid_ext/random.rb",
    "lib/mongoid_ext/slugizer.rb",
    "lib/mongoid_ext/storage.rb",
    "lib/mongoid_ext/tags.rb",
    "lib/mongoid_ext/types/embedded_hash.rb",
    "lib/mongoid_ext/types/open_struct.rb",
    "lib/mongoid_ext/types/timestamp.rb",
    "lib/mongoid_ext/types/translation.rb",
    "lib/mongoid_ext/update.rb",
    "lib/mongoid_ext/versioning.rb",
    "lib/mongoid_ext/voteable.rb",
    "mongoid_ext.gemspec",
    "test/helper.rb",
    "test/models.rb",
    "test/support/custom_matchers.rb",
    "test/test_filter.rb",
    "test/test_modifiers.rb",
    "test/test_paranoia.rb",
    "test/test_random.rb",
    "test/test_slugizer.rb",
    "test/test_storage.rb",
    "test/test_tags.rb",
    "test/test_update.rb",
    "test/test_versioning.rb",
    "test/test_voteable.rb",
    "test/types/test_open_struct.rb",
    "test/types/test_set.rb",
    "test/types/test_timestamp.rb"
  ]
  s.homepage = %q{http://github.com/dcu/mongoid_ext}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{mongoid plugins}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongoid>, ["~> 2"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 2.1.1"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<tzinfo>, [">= 0"])
      s.add_runtime_dependency(%q<differ>, [">= 0.1.2"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_development_dependency(%q<jnunemaker-matchy>, ["~> 0.4"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9.4"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
    else
      s.add_dependency(%q<mongoid>, ["~> 2"])
      s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<differ>, [">= 0.1.2"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<jnunemaker-matchy>, ["~> 0.4"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<mocha>, ["~> 0.9.4"])
      s.add_dependency(%q<timecop>, [">= 0"])
    end
  else
    s.add_dependency(%q<mongoid>, ["~> 2"])
    s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<differ>, [">= 0.1.2"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<jnunemaker-matchy>, ["~> 0.4"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<mocha>, ["~> 0.9.4"])
    s.add_dependency(%q<timecop>, [">= 0"])
  end
end

