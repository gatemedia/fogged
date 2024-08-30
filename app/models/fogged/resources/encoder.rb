# frozen_string_literal: true
module Fogged
  module Resources
    class Encoder
      def self.for(resource)
        "Fogged::Resources::#{provider}Encoder".constantize.new(resource)
      end

      def self.provider
        :AWS if Fogged.provider == :aws
      end
    end
  end
end
