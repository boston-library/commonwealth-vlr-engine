# frozen_string_literal: true

# subclass so we can add FlaggedWarningComponent to page content header
module CommonwealthVlrEngine
  module Document
    class PageHeaderComponent < Blacklight::Document::PageHeaderComponent
      def flagged_warning_component
        CommonwealthVlrEngine::Document::FlaggedWarningComponent.new(document: document)
      end
    end
  end
end
