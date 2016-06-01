module CommonwealthVlrEngine
  module Routes

    extend ActiveSupport::Concern
    included do |klass|
      klass.default_route_sets.unshift(:bookmark_item_actions)
    end

    # route bookmark items actions (cite, email, delete) to folder_items_actions
    # this needs to be before BL bookmarks stuff, so we add it at the beginning of
    # the default_route_sets array
    def bookmark_item_actions(_)
      add_routes do |options|
        put 'bookmarks/item_actions', :to => 'folder_items_actions#folder_item_actions', :as => 'selected_bookmarks_actions'
      end
    end

  end

end
Blacklight::Routes.send(:include, CommonwealthVlrEngine::Routes)