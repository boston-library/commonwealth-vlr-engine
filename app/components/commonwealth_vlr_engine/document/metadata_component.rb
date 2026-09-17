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
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(fields: [], tag: nil, classes: nil, show: false, view_type: nil, field_layout: nil, **component_args)
        @document = component_args[:document]
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Lint/UnusedMethodArgument

      attr_reader :document

      SPECIFIC_NOTE_FIELDS = %w(citation performers venue ownership acquisition date reference physical bibliography
                                exhibitions arrangement language funding biographical publications credits).freeze
      LOCAL_IDENTIFIER_FIELDS = %w[accession other call barcode].freeze
      OTHER_IDENTIFIER_FIELDS = %w[isbn lccn issn ismn isrc issue_number matrix_number music_plate music_publisher
                                   oclcnum sici videorecording].freeze
      PUBLICATION_DATA_FIELDS = %w(edition_name edition_number volume issue_number).freeze
      RIGHTS_FIELDS = %i[rights_ss license_ss rightsstatement_ss].freeze

      def render_rights?
        RIGHTS_FIELDS.any? { |rf| document[rf].present? }
      end

      delegate :blacklight_config, to: :helpers
    end
  end
end
