require "test_helper"

module Fogged
  class ResourcesControllerShowTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    test "should show resource" do
      resource = fogged_resources(:resource_text_1)
      get :show, :id => resource, :use_route => :fogged

      assert_json_resource(resource)
    end

    test "should show video resource" do
      resource = fogged_resources(:resource_mov)
      get :show, :id => resource, :use_route => :fogged

      assert_json_resource(resource)
    end

    test "should show image resource" do
      resource = fogged_resources(:resource_png)
      get :show, :id => resource, :use_route => :fogged

      assert_json_resource(resource)
    end

    test "should not show resource with invalid id" do
      assert_raise(ActiveRecord::RecordNotFound) do
        get :show, :id => 1234567890, :use_route => :foggede
      end
    end
  end
end
