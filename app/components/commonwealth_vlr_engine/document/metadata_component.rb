# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    class MetadataComponent < Blacklight::Component
      # has to use same args as Blacklight::DocumentMetadataComponent,
      # since this gets called from Blacklight::DocumentComponent
      # @param fields [Enumerable<Blacklight::FieldPresenter>] Document field presenters
      # rubocop:disable Metrics/ParameterLists
      # def initialize(fields: [], tag: nil, classes: nil, show: false, view_type: nil, field_layout: nil, **component_args)
      def initialize(document: nil, blacklight_config: nil)
        @document = document
        @blacklight_config = blacklight_config
        # @classes = classes
        # @show = show
        # @view_type = view_type
        # @field_layout = field_layout
        # @component_args = component_args
      end
      # rubocop:enable Metrics/ParameterLists

      attr_reader :document, :blacklight_config
    end
  end
end
