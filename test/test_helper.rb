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

# Run any available migration from dummy app
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)

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
