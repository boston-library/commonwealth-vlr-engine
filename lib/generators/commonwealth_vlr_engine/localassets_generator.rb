# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class LocalassetsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'AssetsGenerator Commonwealth VLR Engine'

    # rubocop:disable Style/IfUnlessModifier
    def assets
      unless IO.read('app/javascript/application.js').include?('commonwealth-vlr-engine')
        append_to_file 'app/javascripts/application.js', "\nimport 'commonwealth-vlr-engine'"
      end

      return if IO.read('app/assets/stylesheets/application.bootstrap.scss').include?('commonwealth-vlr-engine')

      append_to_file 'app/assets/stylesheets/application.bootstrap.scss',
                     "\n@import 'commonwealth-vlr-engine/app/assets/stylesheets/commonwealth-vlr-engine/commonwealth-vlr-engine';"
    end
    # rubocop:enable Style/IfUnlessModifier
  end
end
