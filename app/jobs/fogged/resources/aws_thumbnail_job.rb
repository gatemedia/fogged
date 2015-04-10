module Fogged
  module Resources
    class AWSThumbnailJob < Struct.new(:resource_id, :size, :key)
      def perform
        return unless Fogged.minimagick_enabled
        @resource = Fogged::Resource.find(resource_id)

        Tempfile.open(["thumbnail", ".png"]) do |t|
          MiniMagick::Tool::Convert.new do |c|
            c << @resource.url
            c.resize("#{size}^")
            c.gravity("center")
            c.extent("#{size}")
            c << t.path
          end

          Fogged.resources.files.create(
            :key => key,
            :body => File.read(t.path),
            :public => true,
            :content_type => Mime::PNG.to_s
          )
        end
      end
    end
  end
end
