module ResourceTestHelper
  extend ActiveSupport::Concern
  include JsonTestHelper

  included do
    setup do
      @routes = Fogged::Engine.routes
    end
  end

  private

  def assert_json_resource(resource)
    assert_json_resources([resource], :resource)
  end

  def assert_json_resources(resources, json_key = :resources)
    assert_response :success
    json = response_json[json_key]
    assert_json_objects(resources, json, :id, :url, :name)
    resources.zip([json].flatten).each do |resource, json_resource|
      assert_equal resource.upload_url.chop, json_resource[:upload_url].chop if json_resource[:upload_url]

      next unless resource.video?

      %i[h264_url mpeg_url webm_url thumbnail_urls].each do |field|
        if resource.send(field)
          assert_equal resource.send(field), json_resource[field]
        else
          assert_not json_resource[field]
        end
      end
      assert_equal((resource.encoding_progress || 0), json_resource[:encoding_progress])
    end
  end
end
