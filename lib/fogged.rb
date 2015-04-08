Gem.loaded_specs["fogged"].dependencies.select { |d| d.type == :runtime }.each do |d|
  require d.name
end

require "fogged/engine"
require "fogged/acts_as_having_one_resource"
require "fogged/acts_as_having_many_resources"
require "fogged/with_directory"
require "fogged/utils"

module Fogged
  mattr_accessor :provider
  @@provider = nil

  mattr_accessor :resources
  @@resources = nil

  mattr_accessor :test_enabled
  @@test_enabled = false

  mattr_accessor :storage
  @@storage = nil

  # controller
  mattr_accessor :parent_controller
  @@parent_controller = "ApplicationController"

  # aws
  mattr_accessor :aws_key
  @@aws_key = nil
  mattr_accessor :aws_secret
  @@aws_secret = nil
  mattr_accessor :aws_bucket
  @@aws_bucket = nil
  mattr_accessor :aws_region
  @@aws_region = nil

  # zencoder
  mattr_accessor :zencoder_enabled
  @@zencoder_enabled = false
  mattr_accessor :zencoder_polling_frequency
  @@zencoder_polling_frequency = 10

  def self.configure
    yield self
  end

  def self.resources
    return @@resources if @@resources

    case Fogged.provider
    when :aws
      Fogged.resources = aws_resources
    else
      fail(ArgumentError, "Provider #{Fogged.provider} is not available!")
    end
  end

  def self.test_mode!
    self.test_enabled = true
    @@resources = test_resources
  end

  private

  def self.test_resources
    Fog.mock!
    @@storage = Fog::Storage.new(
      :provider => "AWS",
      :aws_access_key_id => "XXX",
      :aws_secret_access_key => "XXX"
    )
    @@aws_key = "XXX"
    @@aws_secret = "XXX"
    @@aws_bucket = "test"
    @@storage.directories.create(:key => "test")
  end

  def self.aws_resources
    fail(ArgumentError, "AWS key is mandatory") unless Fogged.aws_key
    fail(ArgumentError, "AWS secret is mandatory") unless Fogged.aws_secret
    fail(ArgumentError, "AWS bucket is mandatory") unless Fogged.aws_bucket
    storage_options = {
      :provider => "AWS",
      :aws_access_key_id => Fogged.aws_key,
      :aws_secret_access_key => Fogged.aws_secret
    }
    storage_options.merge!(:region => Fogged.aws_region) if Fogged.aws_region
    @@storage = Fog::Storage.new(storage_options)

    @@storage.directories.get(Fogged.aws_bucket)
  end
end
