require 'rails/generators'

module BlacklightMaps
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc "Install Blacklight-Maps"

    def assets
      copy_file "commonwealth-vlr.css.scss", "app/assets/stylesheets/commonwealth-vlr.css.scss"

      unless IO.read("app/assets/javascripts/application.js").include?('commonwealth-vlr')
        marker = IO.read("app/assets/javascripts/application.js").include?('turbolinks') ?
          '//= require turbolinks' : "//= require jquery_ujs"
        insert_into_file "app/assets/javascripts/application.js", :after => marker do
          %q{
//
// Required by Blacklight-Maps
//= require commonwealth-vlr}
        end
      end
    end
  end
end