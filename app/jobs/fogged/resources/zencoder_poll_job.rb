module Fogged
  module Resources
    class ZencoderPollJob < Struct.new(:resource_id)
      def perform
        return unless Fogged.zencoder_enabled
        @resource = Fogged::Resource.find(resource_id)
        update_encoding_progress

        return if @resource.encoding_progress == 100

        frequency = Fogged.zencoder_polling_frequency
        Delayed::Job.enqueue(self, :run_at => frequency.seconds.from_now)
      end

      private

      def update_encoding_progress
        job = Zencoder::Job.progress(@resource.encoding_job_id)

        case job.body["state"]
        when "finished"
          job = Zencoder::Job.details(@resource.encoding_job_id)
          f = job.body["job"]["output_media_files"][0]
          @resource.update!(
            :encoding_progress => 100,
            :width => f["width"],
            :height => f["height"],
            :duration => f["duration_in_ms"].to_f / 1000.0
          )
        when "processing", "waiting"
          @resource.update!(
            :encoding_progress => job.body["progress"].to_i
          )
        else
          fail(ArgumentError, "Unknown Zencoder job state #{job.body["state"]}")
        end
      end
    end
  end
end
