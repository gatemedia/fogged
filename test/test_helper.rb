# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require "pry"
require "simplecov"
SimpleCov.start "rails"

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require File.expand_path("../test/dummy/config/environment.rb", __dir__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

require "rails/test_help"
require "minitest/unit"
require "mocha/minitest"
require "spawnling"

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end
Fogged.test_mode!

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
  fixtures :all

  def response_json
    @response_json ||= JSON.parse(response.body, symbolize_names: true)
  end

  def in_a_fork
    ActiveRecord::Base.connection.disconnect!
    spawnling = Spawnling.new do
      ActiveRecord::Base.establish_connection
      SimpleCov.at_exit {}
      yield
      ActiveRecord::Base.connection.disconnect!
    end
    Spawnling.wait(spawnling)
  ensure
    ActiveRecord::Base.establish_connection
  end
end
