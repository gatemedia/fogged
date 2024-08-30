# frozen_string_literal: true
require "test_helper"

module Fogged
  class ResourcesControllerCreateTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    def setup
      super
      @resource_params = {
        name: "Dummy",
        filename: "dummy.png",
        content_type: "image/png"
      }
    end

    test "should create resource" do
      assert_difference("Resource.count") do
        post :create, params: { resource: @resource_params }
      end

      assert_json_resource(Resource.last)
      assert_equal "png", Resource.last.extension
    end

    test "should not create resource without resource parameter" do
      assert_no_difference("Resource.count") do
        assert_raise(ActionController::ParameterMissing) do
          post :create
        end
      end
    end

    %i[content_type name].each do |field|
      test "should not create resource without #{field}" do
        assert_no_difference("Resource.count") do
          assert_raise(ActiveRecord::RecordInvalid) do
            post :create,
                 params: { resource: @resource_params.merge(field => "") }
          end
        end
      end
    end

    test "should not create resource without filename" do
      assert_no_difference("Resource.count") do
        assert_raise(ActionController::ParameterMissing) do
          post :create,
               params: { resource: @resource_params.except(:filename) }
        end
      end
    end

    test "should not create resource with invalid filename" do
      assert_no_difference("Resource.count") do
        assert_raise(ActiveRecord::RecordInvalid) do
          post :create,
               params: { resource: @resource_params.merge(filename: "bar") }
        end
      end
    end
  end
end
