# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class MetadataFieldComponent < ViewComponent::Base
      def initialize(document:, field_name:, field_key:, link: false, helper_method: nil)
        @document = document
        @field_name = field_name
        @field_key = field_key
        @link = link
        @helper_method = helper_method
      end
      attr_reader :document, :field_name, :field_key, :link, :helper_method

      def metadata_field_label
        I18n.t("blacklight.metadata_display.fields.#{field_key}")
      end

      def metadata_field_values
        raw_vals = document[field_name]
        raw_vals = [raw_vals] if raw_vals.is_a? String
        raw_vals.map! { |_rv| helpers.public_send(helper_method, document) } if helper_method
        raw_vals.map! { |rv| helpers.link_to_facet(rv, field_name) } if link
        raw_vals.join('<br>')
      end

      def render?
        document[field_name].present?
      end
    end
  end
end
