# frozen_string_literal: true

# so we can use our own template for rendering metadata in catalog#index masonry view
# TODO: remove if unused, prefer using CSS to control layout of fields?
module CommonwealthVlrEngine
  class MasonryDocumentMetadataComponent < Blacklight::Component
    # use same args as Blacklight::DocumentMetadataComponent,
    # since this gets called from Blacklight::DocumentComponent
    # @param fields [Enumerable<Blacklight::FieldPresenter>] Document field presenters
    # rubocop:disable Metrics/ParameterLists
    def initialize(fields: [], tag: nil, classes: nil, show: false, view_type: nil, field_layout: nil, **component_args)
      @fields = fields
    end
    # rubocop:enable Metrics/ParameterLists

    attr_reader :fields

    def genre
      field_value('genre_basic_ssim')
    end

    def field_value(field_name)
      fields.find { |f| f.key == field_name }&.render
    end
  end
end
