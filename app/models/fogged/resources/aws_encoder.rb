module Fogged
  module Resources
    class AWSEncoder
      def initialize(resource)
        @resource = resource
      end

      def encode!
        encode_video if @resource.video?
        encode_image if @resource.image?
      end

      private

      def encode_image
        return unless Fogged.active_job_enabled
        return unless Fogged.minimagick_enabled
        AWSThumbnailJob.perform_later(@resource)
        @resource.update!(:encoding_progress => 0)
      end

      def encode_video
        return unless Fogged.zencoder_enabled
        outputs = output
        if Fogged.zencoder_additional_outputs_block
          additional_outputs = Fogged.zencoder_additional_outputs_block.call(bucket, @resource)
          outputs << additional_outputs
          outputs.flatten!
        end

        params = {
          :input => @resource.url,
          :region => "europe",
          :download_connections => 5,
          :output => outputs
        }

        if Fogged.zencoder_notification_url
          params.merge!(:notifications => [Fogged.zencoder_notification_url])
        end

        @resource.update!(
          :encoding_job_id => Zencoder::Job.create(params).body["id"].to_s,
          :encoding_progress => 0
        )
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
              :filename => "#{@resource.token}-thumbnail-{{number}}",
              :public => 1,
              :width => 1920,
              :height => 1080
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
        @resource.fogged_file.directory.key
      end

      def fogged_name_for(type, number = 0)
        @resource.send(:fogged_name_for, type, number)
      end
    end
  end
end
