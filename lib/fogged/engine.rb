module Fogged
  class Engine < ::Rails::Engine
    isolate_namespace Fogged
    config.fogged = Fogged

    initializer "fogged.detect_zencoder" do
      if defined?(Zencoder) && defined?(Delayed::Job)
        Fogged.zencoder_enabled = true
      end
    end

    initializer "fogged.resources" do
      unless Fogged.test_enabled
        case Fogged.provider
        when :aws
          fail(ArgumentError, "AWS key is mandatory") unless Fogged.aws_key
          fail(ArgumentError, "AWS secret is mandatory") unless Fogged.aws_secret
          fail(ArgumentError, "AWS bucket is mandatory") unless Fogged.aws_bucket
          storage_options = {
            :provider => "AWS",
            :aws_access_key_id => Fogged.aws_key,
            :aws_secret_access_key => Fogged.aws_secret
          }
          storage_options.merge!(:region => Fogged.aws_region) if Fogged.aws_region
          storage = Fog::Storage.new(storage_options)

          Fogged.resources = storage.directories.get(Fogged.aws_bucket)
          if Rails.env.test?
            Fog.mock!
            Fogged.resources = storage.directories.create(:key => Fogged.aws_bucket)
          end
        else
          fail(ArgumentError, "Provider #{Fogged.config.provider} is not available!")
        end
      end
    end

    initializer "fogged.resources.test" do
      if Fogged.test_enabled
        Fog.mock!
        storage = Fog::Storage.new(
          :provider => "AWS",
          :aws_access_key_id => "1234567890",
          :aws_secret_access_key => "1234567890"
        )
        Fogged.resources = storage.directories.create(:key => "test")
      end
    end
  end
end
