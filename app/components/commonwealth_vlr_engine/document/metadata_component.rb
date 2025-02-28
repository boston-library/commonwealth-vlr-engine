# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class MetadataComponent < Blacklight::Component
      # use same args as Blacklight::DocumentMetadataComponent,
      # since this gets called from Blacklight::DocumentComponent
      # @param fields [Enumerable<Blacklight::FieldPresenter>] Document field presenters
      # rubocop:disable Metrics/ParameterLists
      def initialize(fields: [], tag: nil, classes: nil, show: false, view_type: nil, field_layout: nil, **component_args)
        @document = component_args[:document]
        @blacklight_config = component_args[:blacklight_config]
      end
      # rubocop:enable Metrics/ParameterLists

      attr_reader :document, :blacklight_config
    end
  end
end
