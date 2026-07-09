# frozen_string_literal: true

# only rendered in catalog#show (Blacklight::DocumentComponent is rendered in catalog#index)
module CommonwealthVlrEngine
  class DocumentComponent < Blacklight::DocumentComponent
    def initialize(document: nil, presenter: nil, partials: nil,
                   id: nil, classes: [], component: :article, title_component: nil,
                   counter: nil, document_counter: nil, counter_offset: 0,
                   show: false, **args)
      @object_files = args[:object_files]
      @mlt_response = args[:mlt_response]
      super
    end

    renders_one :breadcrumb, lambda {
      helpers.blacklight_config.view_config(:show).breadcrumb_component.new(document: @document)
    }

    renders_one :media, lambda {
      CommonwealthVlrEngine::Document::MediaComponent.new(document: @document, object_files: @object_files)
    }

    renders_one :harvested_item_link, lambda {
      CommonwealthVlrEngine::Document::HarvestedItemComponent.new(document: @document)
    }

    renders_one :show_tools, lambda {
      helpers.blacklight_config.view_config(:show).show_tools_component.new(document: @document)
    }

    renders_one :explore_collection, lambda {
      CommonwealthVlrEngine::ParentPreviewComponent.new(document: @document)
    }

    renders_one :more_like_this, lambda {
      CommonwealthVlrEngine::Document::MoreLikeThisComponent.new(document: @document, mlt_response: @mlt_response)
    }

    renders_one :facet_more, lambda {
      CommonwealthVlrEngine::FacetMoreComponent.new(document: @document)
    }

    # Hack so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      set_slot(:breadcrumb, nil)
      set_slot(:media, nil)
      set_slot(:harvested_item_link, nil)
      set_slot(:show_tools, nil)
      set_slot(:metadata, nil, document: @document) # unless metadata
      set_slot(:explore_collection, nil)
      set_slot(:more_like_this, nil)
      set_slot(:facet_more, nil)
    end
  end
end
