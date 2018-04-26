module Fogged
  module HasOneResource
    extend ActiveSupport::Concern

    module ClassMethods
      DEFAULT_OPTIONS = {
        :dependent => :destroy,
        :class_name => "Fogged::Resource"
      }

      def has_one_resource(*args)
        belongs_to :resource, DEFAULT_OPTIONS.merge(args.extract_options!)
        validate :_check_resource, :unless => -> { resource.blank? }

        define_method(:resource_id) do
          resource.try(:id)
        end

        define_method(:resource_id=) do |id|
          self.resource = id.blank? ? nil : Resource.find(id)
        end
      end
    end

    private

    def _check_resource
      return unless resource.uploading
      errors.add(:resource, I18n.t("fogged.resource.still_uploading"))
    end
  end
end

ActiveRecord::Base.send(:include, Fogged::HasOneResource)
