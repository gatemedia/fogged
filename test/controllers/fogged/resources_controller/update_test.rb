require "test_helper"

module Fogged
  class ResourcesControllerUpdateTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    def setup
      super
      @resource = fogged_resources(:resource_png_1)
    end

    test "should update resource" do
      put :update,
          :id => @resource,
          :resource => { :name => "Update" }

      assert_json_resource(@resource.reload)
    end

    test "should not update resource with invalid id" do
      assert_raise(ActiveRecord::RecordNotFound) do
        put :update,
            :id => 1234567890,
            :resource => { :name => "Update" }
      end
    end
  end
end
