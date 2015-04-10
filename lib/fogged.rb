Gem.loaded_specs["fogged"].dependencies.select { |d| d.type == :runtime }.each do |d|
  require d.name
end

require "fogged/engine"
require "fogged/acts_as_having_one_resource"
require "fogged/acts_as_having_many_resources"
require "fogged/with_directory"
require "fogged/utils"

module Fogged
  mattr_accessor :provider, :_resources, :storage

  mattr_accessor :test_enabled do
    false
  end

  # controller
  mattr_accessor :parent_controller do
    "ApplicationController"
  end

  # aws
  mattr_accessor :aws_key, :aws_secret, :aws_bucket, :aws_region

  # zencoder
  mattr_accessor :zencoder_polling_frequency do
    10
  end

  # thumbnail sizes
  mattr_accessor :thumbnail_sizes do
    []
  end

  # libs support
  mattr_accessor :zencoder_enabled, :minimagick_enabled, :delayed_job_enabled do
    false
  end

  def self.configure
    yield self if block_given?
    self.zencoder_enabled = defined?(Zencoder)
    self.minimagick_enabled = defined?(MiniMagick)
    self.delayed_job_enabled = defined?(Delayed::Job)
  end

  def self.resources
    return Fogged._resources if Fogged._resources

    case Fogged.provider
    when :aws
      Fogged._resources = aws_resources
    else
      fail(ArgumentError, "Provider #{Fogged.provider} is not available!")
    end
  end

  def self.test_mode!
    Fogged.test_enabled = true
    Fogged._resources = test_resources
  end

  private

  def self.test_resources
    Fog.mock!
    Fogged.storage = Fog::Storage.new(
      :provider => "AWS",
      :aws_access_key_id => "XXX",
      :aws_secret_access_key => "XXX"
    )
    Fogged.aws_key = "XXX"
    Fogged.aws_secret = "XXX"
    Fogged.aws_bucket = "test"
    Fogged.storage.directories.create(:key => "test")
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
    Fogged.storage = Fog::Storage.new(storage_options)

    Fogged.storage.directories.get(Fogged.aws_bucket)
  end
end
