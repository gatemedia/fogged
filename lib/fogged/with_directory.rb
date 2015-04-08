module Fogged
  def self.with_directory(directory_name)
    old_resources = @@resources
    @@resources = Fogged.storage.directories.get(directory_name)
    yield
  ensure
    @@resources = old_resources
  end
end
