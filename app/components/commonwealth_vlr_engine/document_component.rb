# frozen_string_literal: true

module CommonwealthVlrEngine
  class DocumentComponent < Blacklight::DocumentComponent
    # renders_one :metadata_vlr, ->(document: @document, blacklight_config: @presenter.blacklight_config) do
    #   # component ||= @presenter&.view_config&.metadata_component || Blacklight::DocumentMetadataComponent
    #   # component.new(document: document, blacklight_config: blacklight_config)
    #   CommonwealthVlrEngine::Document::MetadataComponent.new(document: document, blacklight_config: blacklight_config)
    # end
    # renders_one :metadata_vlr, -> do
    #   CommonwealthVlrEngine::Document::MetadataComponent.new(document: @document,
    #                                                          blacklight_config: helpers.blacklight_config)
    # end

    renders_one :breadcrumb, -> do
      CommonwealthVlrEngine::BreadcrumbComponent.new(document: @document)
    end

    # Hack so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      set_slot(:breadcrumb, nil)
      set_slot(:metadata, nil, document: @document, blacklight_config: helpers.blacklight_config) # unless metadata
    end
  end
end
