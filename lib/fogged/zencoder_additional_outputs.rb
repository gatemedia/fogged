# frozen_string_literal: true
module Fogged
  mattr_accessor :zencoder_additional_outputs_block

  def self.zencoder_additional_outputs(&block)
    Fogged.zencoder_additional_outputs_block = block
  end
end
