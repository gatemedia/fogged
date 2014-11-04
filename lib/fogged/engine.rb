module Fogged
  class Engine < ::Rails::Engine
    isolate_namespace Fogged
    config.fogged = Fogged

    initializer "fogged.resources" do
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
          Fogged.resources = storage.directories.create(:key => Fogged.aws_bucket)
        end
      else
        fail(ArgumentError, "Provider #{Fogged.config.provider} is not available!")
      end
    end
  end
end
