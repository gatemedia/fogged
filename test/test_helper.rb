# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require "pry"
require "simplecov"
SimpleCov.start "rails"

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require "Fog"
Fog.mock!
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "mocha/mini_test"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)

class ActiveSupport::TestCase
  fixtures :all
end
