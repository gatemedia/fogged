# frozen_string_literal: true
require "test_helper"

module Fogged
  class ResourcesControllerShowTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    test "should show resource" do
      resource = fogged_resources(:resource_text_1)
      get :show, params: { id: resource }
      assert_json_resource(resource)
    end

    test "should show video resource" do
      resource = fogged_resources(:resource_mov_1)
      get :show, params: { id: resource }
      assert_json_resource(resource)
    end

    test "should show image resource" do
      resource = fogged_resources(:resource_png_1)
      get :show, params: { id: resource }

      assert_json_resource(resource)
    end

    test "should not show resource with invalid id" do
      assert_raise(ActiveRecord::RecordNotFound) do
        get :show, params: { id: 1_234_567_890 }
      end
    end
  end
end
