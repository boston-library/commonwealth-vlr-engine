# frozen_string_literal: true

# subclass so we can modify search fields on basic search form,
# render our own partial with fulltext checkbox, etc.
# used on "basic search" page (catalog#index with no search params)
module CommonwealthVlrEngine
  class SearchBarComponent < Blacklight::SearchBarComponent
    # simplify text on search field labels
    def search_fields
      super.map { |f| [f[0].gsub(/\s\([\w\s]*\)/, ''), f[1]] }
    end
  end
end
