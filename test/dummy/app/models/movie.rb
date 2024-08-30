class Movie < ActiveRecord::Base
  has_many :movie_fogged_resources
  has_many_resources through: :movie_fogged_resources
end
