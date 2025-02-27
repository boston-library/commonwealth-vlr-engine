# frozen_string_literal: true

module CommonwealthVlrEngine
  class DocumentComponent < Blacklight::DocumentComponent
    renders_one :metadata_vlr, ->(document: @document, blacklight_config: @presenter.blacklight_config) do
      # component ||= @presenter&.view_config&.metadata_component || Blacklight::DocumentMetadataComponent
      # component.new(document: document, blacklight_config: blacklight_config)
      CommonwealthVlrEngine::Document::MetadataComponent.new(document: document, blacklight_config: blacklight_config)
    end
  end
end
