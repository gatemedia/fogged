require "open-uri"

module Fogged
  module Resources
    class AWSThumbnailJob < ActiveJob::Base
      def perform(resource)
        return unless Fogged.minimagick_enabled

        step = 100 / Fogged.thumbnail_sizes.size
        Fogged.thumbnail_sizes.each_with_index do |size, index|
          Tempfile.open(source_from(resource.url), :binmode => true, :encoding => "ascii-8bit") do |source|
            Tempfile.open(["thumbnail", ".png"]) do |t|
              source.write(open(resource.url).read)
              source.flush

              MiniMagick::Tool::Convert.new do |c|
                c << source.path
                c.resize(size.to_s)
                c << t.path
              end

              Fogged.resources.files.create(
                :key => resource.send(:fogged_name_for, :thumbnails, index),
                :body => File.read(t.path),
                :public => true,
                :content_type => Mime[:png].to_s
              )
            end
          end

          resource.increment!(:encoding_progress, step)
        end
        resource.update!(:encoding_progress => 100)
      end

      private

      def source_from(url)
        uri = URI.parse(url)
        extension = File.extname(uri.path)
        [File.basename(uri.path, extension), extension]
      end
    end
  end
end
