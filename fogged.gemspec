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
  s.summary     = "Fogged, a Rails S3 resource helper"
  s.description = "Fogged provides helpers to use S3 resources more easily within Rails"
  s.license     = "MIT"

  s.required_ruby_version = Gem::Requirement.new(">= 3.4", "< 4.1")

  s.files = Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "fastimage", "~> 2.4"
  s.add_dependency "aws-sdk-s3", "~> 1.0"
  s.add_dependency "mime-types", ">= 1.15.0", "< 4.0"
  s.add_dependency "rails", ">= 7.0", "< 9.0"

  s.metadata["rubygems_mfa_required"] = "true"
end
