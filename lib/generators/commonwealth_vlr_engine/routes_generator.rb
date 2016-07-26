require 'rails/generators'

module CommonwealthVlrEngine
  class RoutesGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc """
  This generator makes the following changes to your application:
   1. Injects route declarations into your routes.rb
   2. Removes default routes from basic Blacklight install.
  Thank you for installing Commonwealth VLR.
         """

    # Add CommonwealthVlrEngine to the routes
    def inject_vlr_routes
      unless IO.read("config/routes.rb").include?('CommonwealthVlrEngine::Engine')
        marker = 'Rails.application.routes.draw do'
        insert_into_file "config/routes.rb", :after => marker do
          %q{

  root :to => 'pages#home'

  # routes for CommonwealthVlrEngine
  mount CommonwealthVlrEngine::Engine => '/commonwealth-vlr-engine'

  # user authentication
  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions"}

  # bookmarks item actions
  # this has to be in local app for bookmark item actions to work
  put 'bookmarks/item_actions', :to => 'folder_items_actions#folder_item_actions', :as => 'selected_bookmarks_actions'

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
}
        end

        # remove Blacklight root
        bl_root_marker = 'root to: "catalog#index"'
        gsub_file("config/routes.rb", bl_root_marker, "")

        # change '/catalog' to '/search'
        gsub_file("config/routes.rb", /\/catalog/, "/search")

        # for blacklight_range_limit
        bl_routes_marker = /concerns :searchable.*$/
        inject_into_file 'config/routes.rb', after: bl_routes_marker do
          "\n    concerns :range_searchable\n"
        end

      end
    end

  end
end