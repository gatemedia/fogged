# frozen_string_literal: true
module Fogged
  module HasManyResources
    extend ActiveSupport::Concern

    module ClassMethods
      DEFAULT_OPTIONS = {
        dependent: :destroy,
        class_name: "Fogged::Resource"
      }

      def has_many_resources(*args)
        options = args.extract_options!
        raise(ArgumentError, ":through option is mandatory") unless options.include?(:through)

        has_many :resources, **DEFAULT_OPTIONS.merge(options)
        validate :_check_resources, unless: -> { resources.empty? }
      end
    end

    private

    def _check_resources
      return if resources.to_a.none?(&:uploading)

      errors.add(:resources, I18n.t("fogged.resources.still_uploading"))
    end
  end
end

ActiveRecord::Base.include Fogged::HasManyResources
