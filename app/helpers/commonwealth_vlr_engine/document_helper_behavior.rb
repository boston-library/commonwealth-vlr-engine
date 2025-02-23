# frozen_string_literal: true

module CommonwealthVlrEngine
  module DocumentHelperBehavior
    include Blacklight::DocumentHelperBehavior

    # override so we can set custom presenter for JSON API responses
    def document_presenter_class(document)
      return super unless formats.first == :json

      case action_name
      when 'show'
        CommonwealthVlrEngine::JsonShowPresenter
      when 'index'
        CommonwealthVlrEngine::JsonIndexPresenter
      else
        super
      end
    end
  end
end
