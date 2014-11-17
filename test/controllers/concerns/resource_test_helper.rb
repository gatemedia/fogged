module ResourceTestHelper
  extend ActiveSupport::Concern
  include JsonTestHelper

  private

  def assert_json_resource(resource)
    assert_json_resources([resource], :resource)
  end

  def assert_json_resources(resources, json_key = :resources)
    assert_response :success
    json = response_json[json_key]
    assert_json_objects(resources, json, :id, :url, :name)
    resources.zip([json].flatten).each do |resource, json_resource|
      if json_resource[:upload_url]
        assert_equal resource.upload_url.chop, json_resource[:upload_url].chop
      end

      if resource.video?
        [:h264_url, :mpeg_url, :webm_url, :thumbnail_urls].each do |field|
          assert_equal resource.send(field), json_resource[field]
        end
        assert_equal((resource.encoding_progress || 0), json_resource[:encoding_progress])
      end
    end
  end
end
