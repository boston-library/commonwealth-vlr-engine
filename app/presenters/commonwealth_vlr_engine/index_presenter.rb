# frozen_string_literal: true

# use this to display catalog#index "search results" on pages with a #show action
# otherwise Blacklight removes index fields from IndexPresenter because of #show action name
module CommonwealthVlrEngine
  class IndexPresenter < Blacklight::IndexPresenter

    private

    def display_fields(config = configuration)
      config[:index_fields]
    end
  end
end
