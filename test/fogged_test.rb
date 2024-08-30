# frozen_string_literal: true
require "test_helper"

class FoggedTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Fogged
  end

  test "should return directory public url" do
    assert_equal "https://test.s3.amazonaws.com/", Fogged.directory_public_url("test")
  end

  test "should return resources public url" do
    assert_equal "https://test.s3.amazonaws.com/", Fogged.resources_public_url
  end

  test "should check if file exists" do
    assert_not Fogged.file_exists?("foobar")

    Fogged.resources.files.create(
      key: "foobar",
      body: "foo",
      public: true
    )

    assert Fogged.file_exists?("foobar")
  end
end
