# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class MetadataFieldComponent < ViewComponent::Base
      def initialize(document:, field_name:, field_key:, link: false, helper_method:, helper_method_args: {})
        @document = document
        @field_name = field_name
        @field_key = field_key
        @link = link
        @helper_method = helper_method
        @helper_method_args = helper_method_args
      end
      attr_reader :document, :field_name, :field_key, :link, :helper_method, :helper_method_args

      def metadata_field_label
        I18n.t("blacklight.metadata_display.fields.#{field_key}")
      end

      def metadata_field_values
        if helper_method
          helpers.public_send(helper_method, document)
        else
          document[field_name]
        end
      end

      def metadata_field_label_class
        'col-md-3'
      end

      def metadata_value_label_class
        'col-md-9'
      end
    end
  end
end
