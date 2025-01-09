# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class LocalassetsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'AssetsGenerator Commonwealth VLR Engine'

    # TODO: this all need to be rewritten for Rails 7 pipeline with propshaft, importmaps,
    #       and cssbundling-rails (no sprockets)
    # also need to add `@import "font-awesome";` to app's either:
    #   - app/assets/stylesheets/application.bootstrap.scss
    #   - app/assets/stylesheets/application.css.scss

    def assets
      unless IO.read('app/assets/javascripts/application.js').include?('commonwealth-vlr-engine')
        marker = '//= require blacklight/blacklight'
        insert_into_file 'app/assets/javascripts/application.js', after: marker do
          "\n// Required by Commonwealth-VLR-Engine" \
          "\n//= require bootstrap/carousel" \
          "\n//= require commonwealth-vlr-engine"
        end
      end

      copy_file 'commonwealth_vlr_engine.scss', 'app/assets/stylesheets/commonwealth_vlr_engine.scss'
    end

    # UniversalViewer js has to be copied to local app's public folder
    # because uv.js relies on specific dir structure for components/modules/etc
    # and would be impractical to make it work with Rails asset pipeline
    # similar pattern as Hyrax (https://github.com/samvera/hyrax/commit/0e02c4adf26e74f2d892f575c93789bc166e53ad)
    # though we hard-code the assets instead of installing with yarn
    def uv_assets
      directory 'public/uv-v4' unless File.exist?('public/uv-v4/umd/UV.js')
    end
  end
end
