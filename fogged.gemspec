# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "fogged/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fogged"
  s.version     = Fogged::VERSION
  s.authors     = ["David Fernandez"]
  s.email       = ["david.fernandez@gatemedia.ch"]
  s.homepage    = "https://github.com/gatemedia/fogged"
  s.summary     = "Fogged, a Fog rails helper"
  s.description = "Fogged provides helpers to use Fog resources more easily within Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "active_model_serializers", "~> 0.10.0"
  s.add_dependency "fastimage", "~> 2.0"
  s.add_dependency "fog-aws", "~> 2.0"
  s.add_dependency "mime-types", ">= 1.15.0"
  s.add_dependency "rails", ">= 5.0"

  s.add_development_dependency "delayed_job_active_record", "~> 4.0"
  s.add_development_dependency "mini_magick", "~> 5.0.1"
  s.add_development_dependency "minitest-reporters", "~> 1.0"
  s.add_development_dependency "mocha", "~> 2.0"
  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rails"
  s.add_development_dependency "simplecov", "~> 0.8"
  s.add_development_dependency "spawnling", "~> 2.1"
  s.add_development_dependency "sqlite3", "~> 2.0"
  s.add_development_dependency "zencoder", "~> 2.5"
  s.metadata["rubygems_mfa_required"] = "true"
end
