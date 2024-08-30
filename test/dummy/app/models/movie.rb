# frozen_string_literal: true
class Movie < ApplicationRecord
  has_many :movie_fogged_resources
  has_many_resources through: :movie_fogged_resources
end
