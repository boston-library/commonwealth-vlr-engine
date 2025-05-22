# frozen_string_literal: true

# subclass so we can add FlaggedWarningComponent to page content header
module CommonwealthVlrEngine
  module Document
    class PageHeaderComponent < Blacklight::Document::PageHeaderComponent
      def flagged_warning_component
        CommonwealthVlrEngine::Document::FlaggedWarningComponent.new(document: document)
      end

      def render?
        document[helpers.blacklight_config.flagged_field].present? || super
      end
    end
  end
end
