module Fogged
  def self.directory_public_url(directory_name)
    case Fogged.provider
    when :aws
      Fogged.storage.request_url(:bucket_name => directory_name)
    else
      fail(ArgumentError, "Provider #{Fogged.provider} is not available!")
    end
  end

  def self.resources_public_url
    directory_public_url(Fogged.resources.key)
  end

  def self.file_public_url(key, directory = Fogged.resources.key)
    Fogged.storage.try(
      :request_url,
      :bucket_name => directory,
      :object_name => key
    )
  end
end
