# frozen_string_literal: true

# subclass so we can render our own partial, modify search fields on basic search form
module CommonwealthVlrEngine
  class SearchBarComponent < Blacklight::SearchBarComponent
    # simplify text on search field labels
    def search_fields
      super.map { |f| [f[0].gsub(/\s\([\w\s]*\)/, ''), f[1]] }
    end
  end
end
