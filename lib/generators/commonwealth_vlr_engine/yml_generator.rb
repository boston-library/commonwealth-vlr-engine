# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class YmlGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    class_option :force, type: :boolean, default: false

    desc 'YmlGenerator Commonwealth VLR Engine'

    def config_yml_copy
      source_dest = 'config/vlr.yml'
      copy_file source_dest, source_dest unless File.exist?(source_dest)
    end

    def locale_yml_copy
      copy_file('config/locales/blacklight.en.yml', 'config/locales/blacklight.en.yml', force: options[:force])
    end
  end
end
