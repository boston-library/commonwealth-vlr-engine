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

  # routes for CommonwealthVlrEngine
  mount CommonwealthVlrEngine::Engine => '/commonwealth-vlr-engine'
  root :to => 'pages#home'

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions"}
}
        end

        bl_root_marker = 'root to: "catalog#index"'
        gsub_file("config/routes.rb", bl_root_marker, "")

        bl_catalog_marker = 'blacklight_for :catalog'
        gsub_file("config/routes.rb", bl_catalog_marker, "")

      end
    end

  end
end