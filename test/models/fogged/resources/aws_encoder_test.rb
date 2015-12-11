require "test_helper"

module Fogged
  module Resources
    class AWSEncoderTest < ActiveSupport::TestCase
      test "should not encode video file without delayed job" do
        resource = fogged_resources(:resource_mov_1)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          encoder.encode!

          refute resource.encoding?
          refute resource.encoding_job_id
        end
      end

      test "should not encode video file without zencoder" do
        resource = fogged_resources(:resource_mov_2)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          require "delayed_job_active_record"
          Rails.application.config.active_job.queue_adapter = :delayed_job
          Fogged.configure

          assert_no_difference("Delayed::Job.count") do
            encoder.encode!
          end

          refute resource.encoding?
          refute resource.encoding_job_id
        end
      end

      test "should encode video file" do
        resource = fogged_resources(:resource_mov_3)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          require "zencoder"
          require "delayed_job_active_record"
          Fogged.configure

          Zencoder::Job.expects(:create).returns(
            OpenStruct.new(:body => create_output)
          )
          encoder.encode!

          assert resource.encoding?
          assert_equal 0, resource.encoding_progress
          assert_equal "1234567890", resource.encoding_job_id
        end
      end

      test "should not encode image file without delayed job" do
        resource = fogged_resources(:resource_png_1)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          encoder.encode!

          refute resource.encoding?
          refute resource.encoding_job_id
        end
      end

      test "should not encode image file without minimagick" do
        resource = fogged_resources(:resource_png_2)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          require "delayed_job_active_record"
          Fogged.configure

          assert_no_difference("Delayed::Job.count") do
            encoder.encode!
          end
          refute resource.encoding?
          refute resource.encoding_job_id
        end
      end

      test "should encode image file" do
        resource = fogged_resources(:resource_png_3)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          require "mini_magick"
          require "delayed_job_active_record"
          Rails.application.config.active_job.queue_adapter = :delayed_job
          Fogged.configure
          Fogged.thumbnail_sizes = %w(50x50 60x60)

          assert_difference("Delayed::Job.count") do
            encoder.encode!
          end
          assert resource.encoding?
          assert_equal 0, resource.encoding_progress
        end
      end

      test "should encode video with additional outputs" do
        resource = fogged_resources(:resource_mov_3)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          require "zencoder"
          require "delayed_job_active_record"
          Fogged.configure do |config|
            config.zencoder_additional_outputs do |bucket, res|
              [
                {
                  :url => "s3://#{bucket}/#{res.token}-custom1.mp4",
                  :video_codec => "mpeg4",
                  :quality => 1,
                  :public => 1
                }
              ]
            end
          end

          Zencoder::Job.expects(:create).with() { |options| assert_equal 4, options[:output].size }.returns(
            OpenStruct.new(:body => create_output)
          )
          encoder.encode!

          assert resource.encoding?
          assert_equal 0, resource.encoding_progress
          assert_equal "1234567890", resource.encoding_job_id
        end
      end

      test "should encode video with zencoder notification url" do
        resource = fogged_resources(:resource_mov_3)
        encoder = AWSEncoder.new(resource)

        in_a_fork do
          require "zencoder"
          require "delayed_job_active_record"
          Fogged.configure
          Fogged.stubs(:zencoder_notification_url).returns("http://test")

          Zencoder::Job.expects(:create).with() { |options| assert options[:notifications] }.returns(
            OpenStruct.new(:body => create_output)
          )

          encoder.encode!

          assert resource.encoding?
          assert_equal 0, resource.encoding_progress
          assert_equal "1234567890", resource.encoding_job_id
        end
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
