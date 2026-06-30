# frozen_string_literal: true

# override so we can set render? to return false if there are no facets to display
module CommonwealthVlrEngine
  module Search
    class SidebarComponent < Blacklight::Search::SidebarComponent
      def render?
        @response.facet_fields.values.any? { |ffv| ffv.present? }
      end
    end
  end
end
