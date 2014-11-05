Gem.loaded_specs["fogged"].dependencies.select { |d| d.type == :runtime }.each do |d|
  require d.name
end

require "fogged/engine"
require "fogged/acts_as_having_one_resource"
require "fogged/acts_as_having_many_resources"

module Fogged
  mattr_accessor :provider
  @@provider = nil

  mattr_accessor :resources
  @@resources = nil

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
end
