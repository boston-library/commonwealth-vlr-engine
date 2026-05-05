# frozen_string_literal: true

# simple search form with one input, no field selection, etc
module CommonwealthVlrEngine
  class SimpleSearchBarComponent < Blacklight::SearchBarComponent
    def search_fields
      []
    end

    def advanced_search_enabled?
      false
    end
  end
end
