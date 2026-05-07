# frozen_string_literal: true

# subclass so we can render custom search bar inside <nav>
module CommonwealthVlrEngine
  class TopNavbarComponent < Blacklight::TopNavbarComponent
    renders_one :search_bar, lambda { |component: CommonwealthVlrEngine::SimpleSearchBarComponent|
      component.new(
        url: helpers.search_catalog_url,
        advanced_search_url: helpers.blacklight_advanced_search_engine.advanced_search_url,
        classes: %w[simple-search-query-form header-search-query-form],
        params: helpers.search_state.params_for_search.except(*params_to_ignore),
        autocomplete_path: suggest_index_catalog_path
      )
    }

    # modify params so that unwanted keys/values are not added when
    # SimpleSearchBarComponent rendered on collections#* or instutitons#* views
    def params_to_ignore
      return :qt if controller_name == 'catalog'

      %i[coordinates f page per_page sort qt starts_with view]
    end

    # Hack so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      with_search_bar unless search_bar || action_name == 'home'
    end
  end
end
