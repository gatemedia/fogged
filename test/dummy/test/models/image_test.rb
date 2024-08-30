# frozen_string_literal: true
require "test_helper"

class ImageTest < ActiveSupport::TestCase
  def setup
    super
    @image = Image.new(name: "test")
  end

  test "should save image without resource" do
    assert @image.save
  end

  test "should save image with uploaded resource" do
    assert @image.update(resource: fogged_resources(:resource_text_1))
  end

  test "should not save image with uploading resource" do
    resource = fogged_resources(:resource_text_1)
    resource.update!(uploading: true)

    assert_not @image.update(resource:)
  end

  test "image url changing the storage name" do
    d = "foobar"
    @image.update!(resource: fogged_resources(:resource_png_1))
    Fogged.storage.directories.create(key: d)

    url = Fogged.with_directory(d) { @image.resource.url }

    assert url.include?(d)
    assert_not @image.resource.url.include?(d)
  end
end
