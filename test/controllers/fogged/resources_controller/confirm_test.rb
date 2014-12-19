require "test_helper"

module Fogged
  class ResourcesControllerConfirmTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    test "should confirm resource" do
      resource = fogged_resources(:resource_png)

      put :confirm, :id => resource, :use_route => :fogged

      assert_json_resource(resource.reload)
      assert_equal 800, resource.width
      assert_equal 600, resource.height
      refute resource.encoding?
    end

    test "should confirm video resource with zencoder enabled" do
      in_a_fork do
        require "zencoder"
        require "delayed_job_active_record"

        Fogged.zencoder_enabled = true

        Zencoder::Job.expects(:create).returns(
          OpenStruct.new(:body => create_output)
        )
        resource = fogged_resources(:resource_mov)

        assert_difference("Delayed::Job.count") do
          put :confirm, :id => resource, :use_route => :fogged
        end

        assert_json_resource(resource.reload)
        assert resource.encoding_job_id
        assert resource.encoding?
      end
    end

    test "should not confirm resource with invalid id" do
      assert_raise(ActiveRecord::RecordNotFound) do
        put :confirm, :id => 123456, :use_route => :fogged
      end
    end

    private

    def create_output
      {
        :id => 1234567890
      }.with_indifferent_access
    end
  end
end
