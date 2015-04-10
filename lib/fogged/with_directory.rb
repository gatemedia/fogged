module Fogged
  def self.with_directory(directory_name)
    old_resources = Fogged._resources
    Fogged._resources = Fogged.storage.directories.get(directory_name)
    yield
  ensure
    Fogged._resources = old_resources
  end
end
