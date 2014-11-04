require "test_helper"

module Fogged
  module Resources
    class ZencoderPollJobTest < ActiveSupport::TestCase
      def setup
        super
        @resource = fogged_resources(:resource_mov)
        @resource.update!(
          :encoding_job_id => 1234567890,
          :encoding_progress => 10
        )
        @job = ZencoderPollJob.new(@resource.id)
      end

      test "should poll job with status success" do
        Zencoder::Job.expects(:progress).with("1234567890").returns(
          OpenStruct.new(:body => progress_output("finished"))
        )
        Zencoder::Job.expects(:details).with("1234567890").returns(
          OpenStruct.new(:body => details_output)
        )

        assert_no_difference("Delayed::Job.count") do
          @job.perform
        end
        refute @resource.reload.encoding?
        assert_equal 800, @resource.width
        assert_equal 600, @resource.height
        assert_equal 15, @resource.duration
      end

      %w(processing waiting).each do |status|
        test "should poll job with status #{status}" do
          Zencoder::Job.expects(:progress).with("1234567890").returns(
            OpenStruct.new(:body => progress_output(status))
          )

          assert_difference("Delayed::Job.count") do
            @job.perform
          end
          assert @resource.reload.encoding?
          assert_equal 55, @resource.encoding_progress
        end
      end

      test "should poll job with status unknown" do
        Zencoder::Job.expects(:progress).with("1234567890").returns(
          OpenStruct.new(:body => progress_output("unknown"))
        )

        assert_raise(ArgumentError) do
          assert_no_difference("Delayed::Job.count") do
            @job.perform
          end
        end
      end

      private

      def progress_output(state)
        {
          :state => state,
          :progress => "55.5"
        }.with_indifferent_access
      end

      def details_output
        {
          :job => {
            :output_media_files => [{
              :width => 800,
              :height => 600,
              :duration_in_ms => 15753
            }]
          }
        }.with_indifferent_access
      end
    end
  end
end
