module Fogged
  def self.with_directory(directory_name)
    old_resources = Fogged.resources
    Fogged.resources = Fogged.storage.directories.get(directory_name)
  ensure
    Fogged.resources = old_resources
  end
end
