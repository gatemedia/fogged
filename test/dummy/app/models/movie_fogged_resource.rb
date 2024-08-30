# frozen_string_literal: true
class MovieFoggedResource < ApplicationRecord
  belongs_to :movie
  belongs_to :resource, class_name: "Fogged::Resource"
end
