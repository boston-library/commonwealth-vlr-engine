require 'rails/generators'

module CommonwealthVlrEngine
  class AssetsGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc "AssetsGenerator Commonwealth VLR Engine"

    def assets
      copy_file "commonwealth-vlr-engine.css.scss", "app/assets/stylesheets/commonwealth-vlr-engine.css.scss"

      unless IO.read("app/assets/javascripts/application.js").include?('commonwealth-vlr-engine')
        marker = IO.read("app/assets/javascripts/application.js").include?('turbolinks') ?
            '//= require turbolinks' : "//= require jquery_ujs"
        insert_into_file "app/assets/javascripts/application.js", :after => marker do
          %q{
//
// Required by Commonwealth-VLR-Engine
//= require commonwealth-vlr-engine}
        end
      end

      unless IO.read("app/assets/stylesheets/application.css").include?('commonwealth-vlr-engine')
        marker = '*/'
        insert_into_file "app/assets/stylesheets/application.css", :before => marker do
          %q{*
*= require commonwealth-vlr-engine
*}
        end
      end

    end

  end
end