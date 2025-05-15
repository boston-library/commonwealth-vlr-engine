# frozen_string_literal: true

# only called from catalog#show, though Blacklight::DocumentComponent is used in both #index and #show
module CommonwealthVlrEngine
  class DocumentComponent < Blacklight::DocumentComponent
    renders_one :breadcrumb, -> do
      CommonwealthVlrEngine::BreadcrumbComponent.new(document: @document)
    end

    renders_one :media, -> do
      puts "OBJECT_FILES = #{@object_files}"
      CommonwealthVlrEngine::Document::MediaComponent.new(document: @document, object_files: @object_files)
    end

    # Hack so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      set_slot(:breadcrumb, nil)
      set_slot(:media, nil)
      set_slot(:metadata, nil, document: @document) # unless metadata
    end
  end
end
