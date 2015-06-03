require 'rails/generators'

module CommonwealthVlrEngine
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc "Install Commonwealth VLR Engine"

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
    end
  end
end