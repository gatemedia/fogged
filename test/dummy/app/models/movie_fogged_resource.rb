class MovieFoggedResource < ActiveRecord::Base
  belongs_to :movie
  belongs_to :resource, :class_name => "Fogged::Resource"
end
