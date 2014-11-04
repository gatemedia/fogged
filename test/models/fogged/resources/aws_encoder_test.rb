require "test_helper"

module Fogged
  module Resources
    class AWSEncoderTest < ActiveSupport::TestCase
      def setup
        super
        @resource = fogged_resources(:resource_mov)
        @encoder = AWSEncoder.new(@resource)
      end

      test "should encode video file" do
        Zencoder::Job.expects(:create).returns(
          OpenStruct.new(:body => create_output)
        )
        assert_difference("Delayed::Job.count") do
          @encoder.encode!
        end

        assert @resource.encoding?
        assert_equal 0, @resource.encoding_progress
        assert_equal "1234567890", @resource.encoding_job_id
      end

      test "should not encode image file" do
        @resource = fogged_resources(:resource_png)
        @encoder = AWSEncoder.new(@resource)

        assert_no_difference("Delayed::Job.count") do
          @encoder.encode!
        end
        refute @resource.encoding?
        refute @resource.encoding_job_id
      end

      private

      def create_output
        {
          :id => 1234567890
        }.with_indifferent_access
      end
    end
  end
end
