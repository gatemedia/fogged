module Fogged
  module Resources
    class AWSEncoder < Struct.new(:resource)
      def encode!
        return unless Fogged.active_job_enabled
        encode_video if resource.video?
        encode_image if resource.image?
      end

      private

      def encode_image
        return unless Fogged.minimagick_enabled
        Delayed::Job.enqueue(AWSThumbnailJob.new(resource.id))
        resource.update!(
          :encoding_progress => 0
        )
      end

      def encode_video
        return unless Fogged.zencoder_enabled

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
        resource.fogged_file.directory.key
      end

      def fogged_name_for(type, number = 0)
        resource.send(:fogged_name_for, type, number)
      end
    end
  end
end
