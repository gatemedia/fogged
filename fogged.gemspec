$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fogged/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fogged"
  s.version     = Fogged::VERSION
  s.authors     = ["David Fernandez"]
  s.email       = ["david.fernandez@gatemedia.ch"]
  s.homepage    = "https://github.com/gatemedia"
  s.summary     = "Fogged, a Fog rails helper"
  s.description = "Fogged provides helpers to use Fog resources more easily within Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1"
  s.add_dependency "fog", "~> 1.22"
  s.add_dependency "fastimage", "~> 1.6"
  s.add_dependency "active_model_serializers", "~> 0.8"

  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "mocha", "~> 1.1"
  s.add_development_dependency "minitest-reporters", "~> 1.0"
  s.add_development_dependency "simplecov", "~> 0.8"
  s.add_development_dependency "zencoder", "~> 2.5"
  s.add_development_dependency "delayed_job_active_record", "~> 4.0"
end
