require "test_helper"

class FoggedTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Fogged
  end

  test "should return directory public url" do
    assert_equal "https://test.s3.amazonaws.com/", Fogged.directory_public_url("test")
  end
end
