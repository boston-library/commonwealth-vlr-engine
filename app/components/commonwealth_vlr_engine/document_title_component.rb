# frozen_string_literal: true

# used when rendering search results or lists of items on a page with a #show action
# otherwise, Blacklight::UrlHelperBehavior#link_to_document will use #show title method
module CommonwealthVlrEngine
  class DocumentTitleComponent < Blacklight::DocumentTitleComponent
    def title
      @title = helpers.index_title(document: presenter.document) if presenter.kind_of?(CommonwealthVlrEngine::IndexPresenter)
      super
    end
  end
end
