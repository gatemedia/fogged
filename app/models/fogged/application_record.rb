# frozen_string_literal: true
module Fogged
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
