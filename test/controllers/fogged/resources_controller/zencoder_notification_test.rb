require "test_helper"

module Fogged
  class ResourcesControllerZencoderNotificationTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    setup do
      @resource = fogged_resources(:resource_mov_3)
      @resource.update!(encoding_job_id: 1_234_565_434_567_890)
    end

    test "should receive zencoder notification" do
      assert_not @resource.encoding_progress
      assert_not @resource.width
      assert_not @resource.height
      assert_not @resource.duration

      post :zencoder_notification, params: payload(@resource.encoding_job_id)

      assert @resource.reload.encoding_progress
      assert @resource.width
      assert @resource.height
      assert @resource.duration
    end

    test "should receive zencoder notification with invalid id" do
      post :zencoder_notification, params: payload("foobar!")
    end

    test "should receive zencoder notification with invalid payload" do
      assert_not @resource.encoding_progress
      assert_not @resource.width
      assert_not @resource.height
      assert_not @resource.duration

      post :zencoder_notification,
           params: payload(@resource.encoding_job_id).except(:outputs)

      assert_not @resource.reload.encoding_progress
      assert_not @resource.width
      assert_not @resource.height
      assert_not @resource.duration
    end

    test "should receive zencoder notification with failed job" do
      assert_not @resource.encoding_progress
      assert_not @resource.width
      assert_not @resource.height
      assert_not @resource.duration

      post :zencoder_notification,
           params: payload(@resource.encoding_job_id, "failed")

      assert_not @resource.reload.encoding_progress
      assert_not @resource.width
      assert_not @resource.height
      assert_not @resource.duration
    end

    private

    def payload(encoding_job_id, state = "finished")
      {
        job: {
          id: encoding_job_id,
          state:
        },
        outputs: [
          { duration_in_ms: 85_600, height: 480, width: 640 }
        ]
      }
    end
  end
end
