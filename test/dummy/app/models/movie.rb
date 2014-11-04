class Movie < ActiveRecord::Base
  has_many :movie_fogged_resources
  acts_as_having_many_resources :through => :movie_fogged_resources
end
