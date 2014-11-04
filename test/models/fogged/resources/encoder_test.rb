require "test_helper"

module Fogged
  module Resources
    class EncoderTest < ActiveSupport::TestCase
      def setup
        super
        @resource = fogged_resources(:resource_mov)
      end

      test "should aws encoder" do
        encoder = Encoder.for(@resource)

        assert encoder.is_a?(AWSEncoder)
      end
    end
  end
end
