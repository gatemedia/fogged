require "test_helper"

module Fogged
  class ResourcesControllerConfirmTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    test "should confirm resource" do
      resource = fogged_resources(:resource_png)
      FastImage.expects(:size).once.returns([800, 600])

      assert_no_difference("Delayed::Job.count") do
        put :confirm, :id => resource, :use_route => :fogged
      end
      assert_json_resource(resource.reload)
      assert_equal 800, resource.width
      assert_equal 600, resource.height
      refute resource.encoding?
    end

    test "should not confirm resource with invalid id" do
      assert_raise(ActiveRecord::RecordNotFound) do
        put :confirm, :id => 123456, :use_route => :fogged
      end
    end
  end
end
