# frozen_string_literal: true
require "test_helper"

class FoggedTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Fogged
  end

  test "should require AWS region" do
    previous_region = Fogged.aws_region
    Fogged.aws_region = nil

    error = assert_raise(ArgumentError) do
      Fogged.configure
    end
    assert_equal "AWS region is mandatory", error.message
  ensure
    Fogged.aws_region = previous_region
  end

  test "should reject blank AWS configuration values" do
    {
      "AWS key is mandatory" => [
        -> { Fogged.aws_key },
        ->(value) { Fogged.aws_key = value }
      ],
      "AWS secret is mandatory" => [
        -> { Fogged.aws_secret },
        ->(value) { Fogged.aws_secret = value }
      ],
      "AWS bucket is mandatory" => [
        -> { Fogged.aws_bucket },
        ->(value) { Fogged.aws_bucket = value }
      ],
      "AWS region is mandatory" => [
        -> { Fogged.aws_region },
        ->(value) { Fogged.aws_region = value }
      ]
    }.each do |message, (getter, setter)|
      previous_value = getter.call
      setter.call("")

      error = assert_raise(ArgumentError) do
        Fogged.configure
      end
      assert_equal message, error.message
    ensure
      setter.call(previous_value)
    end
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
