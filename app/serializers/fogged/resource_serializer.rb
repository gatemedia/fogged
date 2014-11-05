module Fogged
  class ResourceSerializer < ActiveModel::Serializer
    attributes :id, :name, :upload_url, :url
    attributes :h264_url, :mpeg_url, :webm_url, :thumbnail_urls
    attributes :encoding_progress

    def include_upload_url?
      options[:include_upload_url]
    end

    def include_h264_url?
      object.video?
    end

    def include_mpeg_url?
      object.video?
    end

    def include_webm_url?
      object.video?
    end

    def include_thumbnail_urls?
      object.video?
    end

    def include_encoding_progress?
      object.video?
    end

    def encoding_progress
      object.encoding_progress || 0
    end
  end
end
