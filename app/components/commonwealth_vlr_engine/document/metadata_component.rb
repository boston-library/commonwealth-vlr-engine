# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class MetadataComponent < Blacklight::Component
      # used in catalog#show view
      # this gets called from CommonwealthVlrEngine::DocumentComponent,
      # which is a subclass of Blacklight::DocumentComponent,
      # so use same args as Blacklight::DocumentMetadataComponent, even though most are unused
      # @param fields [Enumerable<Blacklight::FieldPresenter>] Document field presenters
      # rubocop:disable Metrics/ParameterLists
      def initialize(fields: [], tag: nil, classes: nil, show: false, view_type: nil, field_layout: nil, **component_args)
        @document = component_args[:document]
      end
      # rubocop:enable Metrics/ParameterLists

      attr_reader :document

      def blacklight_config
        helpers.blacklight_config
      end
    end
  end
end
