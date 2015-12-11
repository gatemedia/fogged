require "test_helper"

module Fogged
  class ResourcesControllerZencoderNotificationTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    setup do
      @resource = fogged_resources(:resource_mov_3)
      @resource.update!(:encoding_job_id => 1234565434567890)
    end

    test "should receive zencoder notification" do
      refute @resource.encoding_progress
      refute @resource.width
      refute @resource.height
      refute @resource.duration

      post :zencoder_notification, payload(@resource.encoding_job_id)

      assert @resource.reload.encoding_progress
      assert @resource.width
      assert @resource.height
      assert @resource.duration
    end

    test "should receive zencoder notification with invalid id" do
      post :zencoder_notification, payload("foobar!")
    end

    test "should receive zencoder notification with invalid payload" do
      refute @resource.encoding_progress
      refute @resource.width
      refute @resource.height
      refute @resource.duration

      post :zencoder_notification,
           payload(@resource.encoding_job_id).except(:outputs)

      refute @resource.reload.encoding_progress
      refute @resource.width
      refute @resource.height
      refute @resource.duration
    end

    test "should receive zencoder notification with failed job" do
      refute @resource.encoding_progress
      refute @resource.width
      refute @resource.height
      refute @resource.duration

      post :zencoder_notification, payload(@resource.encoding_job_id, "failed")

      refute @resource.reload.encoding_progress
      refute @resource.width
      refute @resource.height
      refute @resource.duration
    end

    private

    def payload(encoding_job_id, state = "finished")
      {
        :job => {
          :id => encoding_job_id,
          :state => state
        },
        :outputs => [
          { :duration_in_ms => 85600, :height => 480, :width => 640 }
        ]
      }
    end
  end
end
