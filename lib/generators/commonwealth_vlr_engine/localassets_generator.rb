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
//= require commonwealth-vlr-engine
//= require bootstrap/carousel

}
        end
      end

      copy_file "commonwealth_vlr_engine.css.scss", "app/assets/stylesheets/commonwealth_vlr_engine.css.scss"
=begin
      unless IO.read("app/assets/stylesheets/application.css").include?('commonwealth_vlr_engine')
        marker = '*= require_tree'
        insert_into_file "app/assets/stylesheets/application.css", :before => marker do
          %q{*
 *= require commonwealth_vlr_engine
}
        end
      end
=end
    end

  end
end