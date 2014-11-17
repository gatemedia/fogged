require "test_helper"

module Fogged
  class ResourcesControllerCreateTest < ActionController::TestCase
    tests ResourcesController
    include ResourceTestHelper

    def setup
      super
      @resource_params = {
        :name => "Dummy",
        :filename => "dummy.png",
        :content_type => "image/png"
      }
    end

    test "should create resource" do
      assert_difference("Resource.count") do
        post :create, :resource => @resource_params, :use_route => :fogged
      end

      assert_json_resource(Resource.last)
      assert_equal "png", Resource.last.extension
    end

    test "should not create resource without resource parameter" do
      assert_no_difference("Resource.count") do
        assert_raise(ActionController::ParameterMissing) do
          post :create, :use_route => :fogged
        end
      end
    end

    [:filename, :content_type, :name].each do |field|
      test "should not create resource without #{field}" do
        assert_no_difference("Resource.count") do
          assert_raise(ActionController::ParameterMissing) do
            post :create,
                 :resource => @resource_params.merge(field => ""),
                 :use_route => :fogged
          end
        end
      end
    end

    test "should not create resource with invalid filename" do
      assert_no_difference("Resource.count") do
        assert_raise(ActiveRecord::RecordInvalid) do
          post :create,
               :resource => @resource_params.merge(:filename => "bar"),
               :use_route => :fogged
        end
      end
    end
  end
end
