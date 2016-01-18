module Fogged
  module Resources
    class AWSThumbnailJob < ActiveJob::Base
      def perform(resource)
        return unless Fogged.minimagick_enabled

        step = 100 / Fogged.thumbnail_sizes.size
        Fogged.thumbnail_sizes.each_with_index do |size, index|
          Tempfile.open(["thumbnail", ".png"]) do |t|
            MiniMagick::Tool::Convert.new do |c|
              c << resource.url
              c.resize("#{size}")
              c << t.path
            end

            Fogged.resources.files.create(
              :key => resource.send(:fogged_name_for, :thumbnails, index),
              :body => File.read(t.path),
              :public => true,
              :content_type => Mime::PNG.to_s
            )
          end

          resource.increment!(:encoding_progress, step)
        end
        resource.update!(:encoding_progress => 100)
      end
    end
  end
end
