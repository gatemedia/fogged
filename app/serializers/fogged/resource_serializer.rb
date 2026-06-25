# frozen_string_literal: true
module Fogged
  class ResourceSerializer
    def initialize(resource, include_upload_url: false)
      @resource = resource
      @include_upload_url = include_upload_url
    end

    def as_json(*)
      {
        id: resource.id,
        name: resource.name,
        url: resource.url
      }.tap do |json|
        json[:upload_url] = resource.upload_url if include_upload_url
        add_video_fields(json) if resource.video?
      end
    end

    private

    attr_reader :resource, :include_upload_url

    def add_video_fields(json)
      json[:h264_url] = resource.h264_url
      json[:mpeg_url] = resource.mpeg_url
      json[:webm_url] = resource.webm_url
      json[:thumbnail_urls] = resource.thumbnail_urls
      json[:encoding_progress] = resource.encoding_progress || 0
    end
  end
end
