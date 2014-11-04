module Fogged
  module Resources
    class Encoder
      def self.for(resource)
        "Fogged::Resources::#{provider_for(resource)}Encoder".constantize.new(resource)
      end

      def self.provider_for(resource)
        return :AWS if resource.send(:fogged_file).class.to_s.include?("AWS")
      end
    end
  end
end
