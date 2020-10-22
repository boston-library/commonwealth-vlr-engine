# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class RoutesGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc "This generator makes the following changes to your application:
          1. Injects route declarations into your routes.rb
          2. Modifies default routes from basic Blacklight install."

    # Add CommonwealthVlrEngine to the routes
    def inject_vlr_routes
      return if IO.read('config/routes.rb').include?('CommonwealthVlrEngine::Engine')

      marker = 'Rails.application.routes.draw do'
      insert_into_file 'config/routes.rb', after: marker do
        %q(

  root to: 'pages#home'

  # bookmarks item actions
  # this has to be in local app for bookmark item actions to work
  put 'bookmarks/item_actions', to: 'folder_items_actions#folder_item_actions', as: 'selected_bookmarks_actions'

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :iiif_search, BlacklightIiifSearch::Routes.new
)
      end

      # comment out Blacklight root
      bl_root_marker = 'root to: "catalog#index"'
      gsub_file('config/routes.rb', bl_root_marker, "# #{bl_root_marker}")

      # change '/catalog' to '/search'
      gsub_file('config/routes.rb', /\/catalog/, '/search')

      # for blacklight_range_limit
      searchable_marker = /concerns :searchable.*$/
      inject_into_file 'config/routes.rb', after: searchable_marker do
        "\n    concerns :range_searchable"
      end

      # for blacklight_iiif_search
      exportable_marker = /concerns :exportable.*$/
      inject_into_file 'config/routes.rb', after: exportable_marker do
        "\n    concerns :iiif_search"
      end
    end
  end
end
