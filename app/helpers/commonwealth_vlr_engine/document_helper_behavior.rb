# frozen_string_literal: true

module CommonwealthVlrEngine
  module DocumentHelperBehavior
    include Blacklight::DocumentHelperBehavior

    # override so we can set custom presenter for JSON API responses
    def document_presenter_class(document)
      formats.first == :json ? CommonwealthVlrEngine::JsonIndexPresenter : super
    end
  end
end
