require "test_helper"

class ImageTest < ActiveSupport::TestCase
  def setup
    super
    @image = Image.new(:name => "test")
  end

  test "should save image without resource" do
    assert @image.save
  end

  test "should save image with uploaded resource" do
    assert @image.update(:resource => fogged_resources(:resource_text_1))

  end

  test "should not save image with uploading resource" do
    resource = fogged_resources(:resource_text_1)
    resource.update!(:uploading => true)

    refute @image.update(:resource => resource)
  end
end
