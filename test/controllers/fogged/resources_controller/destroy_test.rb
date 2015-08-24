require "test_helper"

module Fogged
  class ResourcesControllerDestroyTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    def setup
      super
      @resource = fogged_resources(:resource_png_1)
    end

    test "should destroy resource" do
      assert_difference("Resource.count", -1) do
        delete :destroy, :id => @resource
      end

      assert_response :no_content
      assert response.body.blank?
    end

    test "should not destroy resource with invalid id" do
      assert_no_difference("Resource.count") do
        assert_raise(ActiveRecord::RecordNotFound) do
          delete :destroy, :id => 123456
        end
      end
    end
  end
end
