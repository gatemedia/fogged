module Fogged
  module ActsAsHavingManyResources
    extend ActiveSupport::Concern

    module ClassMethods
      DEFAULT_OPTIONS = {
        :dependent => :destroy,
        :class_name => "Fogged::Resource"
      }

      def acts_as_having_many_resources(*args)
        options = args.extract_options!
        unless options.include?(:through)
          fail(ArgumentError, ":through option is mandatory")
        end
        has_many :resources, DEFAULT_OPTIONS.merge(options)
        validate :_check_resources, :unless => "resources.empty?"
      end
    end

    private

    def _check_resources
      return if resources.to_a.select(&:uploading).empty?
      errors.add(:resources, I18n.t("fogged.resources.still_uploading"))
    end
  end
end

ActiveRecord::Base.send(:include, Fogged::ActsAsHavingManyResources)
