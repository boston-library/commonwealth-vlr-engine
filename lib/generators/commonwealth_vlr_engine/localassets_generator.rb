require 'rails/generators'

module CommonwealthVlrEngine
  class LocalassetsGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc "AssetsGenerator Commonwealth VLR Engine"

    def assets
      unless IO.read("app/assets/javascripts/application.js").include?('commonwealth-vlr-engine')
        marker = '//= require_tree .'
        insert_into_file "app/assets/javascripts/application.js", :before => marker do
          %q{
//
// Required by Commonwealth-VLR-Engine
//= require bootstrap/carousel
//= require commonwealth-vlr-engine

}
        end
      end

      copy_file "commonwealth_vlr_engine.scss", "app/assets/stylesheets/commonwealth_vlr_engine.scss"

    end

  end
end