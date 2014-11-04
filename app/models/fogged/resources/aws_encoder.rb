module Fogged
  module Resources
    class AWSEncoder < Struct.new(:resource)
      def encode!
        encode_video if resource.video?
      end

      private

      def encode_video
        fail(ArgumentError, "Zencoder gem needed") unless defined?(Zencoder)
        fail(ArgumentError, "Delayed Job gem needed") unless defined?(Delayed::Job)

        job = Zencoder::Job.create(
          :input => resource.url,
          :region => "europe",
          :download_connections => 5,
          :output => output
        )
        resource.update!(
          :encoding_job_id => job.body["id"].to_s,
          :encoding_progress => 0
        )

        Delayed::Job.enqueue(ZencoderPollJob.new(resource.id))
      end

      def output
        [
          {
            :url => "s3://#{bucket}/#{fogged_name_for(:h264)}",
            :video_codec => "h264",
            :public => 1,
            :thumbnails => {
              :number => 5,
              :format => "png",
              :base_url => "s3://#{bucket}",
              :filename => "#{resource.token}-thumbnail-{{number}}",
              :public => 1
            }
          },
          {
            :url => "s3://#{bucket}/#{fogged_name_for(:mpeg)}",
            :video_codec => "mpeg4",
            :public => 1
          },
          {
            :url => "s3://#{bucket}/#{fogged_name_for(:webm)}",
            :video_codec => "vp8",
            :public => 1
          }
        ]
      end

      def bucket
        resource.send(:fogged_file).directory.key
      end

      def fogged_name_for(type)
        resource.send(:fogged_name_for, type)
      end
    end
  end
end
