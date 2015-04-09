# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require "pry"
require "simplecov"
SimpleCov.start "rails"

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)

require "rails/test_help"
require "mocha/mini_test"

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActiveSupport::TestCase.fixtures :all
end
Fogged.test_mode!

class ActiveSupport::TestCase
  fixtures :all

  def response_json
    @response_json ||= JSON.parse(response.body, :symbolize_names => true)
  end

  # helper for fork testing
  def in_a_fork
    ActiveRecord::Base.connection.disconnect!
    begin
      rout, wout = IO.pipe
      pid = fork do
        STDERR.reopen(wout)
        begin
          ActiveRecord::Base.establish_connection
          yield
        ensure
          ActiveRecord::Base.connection.disconnect!
        end

        SimpleCov.at_exit {}
      end
      Process.waitpid(pid)
      wout.close
      result = rout.readlines
      unless result.empty?
        result.each { |r| STDERR.puts r }
        fail("Test in a fork has failed")
      end
    ensure
      ActiveRecord::Base.establish_connection
    end
  end
end
