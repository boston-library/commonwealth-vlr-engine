require 'rails/generators'

module CommonwealthVlrEngine
  class YmlGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    class_option :force, type: :boolean, default: false

    desc 'YmlGenerator Commonwealth VLR Engine'

    def config_yml_copy
      copy_file 'config/geojson_static_file.yml.sample', 'config/geojson_static_file.yml' unless File::exists?('config/geojson_static_file.yml')
      copy_file 'config/google_analytics.yml.sample', 'config/google_analytics.yml' unless File::exists?('config/google_analytics.yml')
      copy_file 'config/contact_emails.yml.sample', 'config/contact_emails.yml' unless File::exists?('config/contact_emails.yml')
      copy_file 'config/fedora.yml.sample', 'config/fedora.yml' unless File::exists?('config/fedora.yml')
      copy_file 'config/iiif_server.yml.sample', 'config/iiif_server.yml' unless File::exists?('config/iiif_server.yml')
      copy_file 'config/vlr.yml', 'config/vlr.yml' unless File::exists?('config/vlr.yml')
    end

    def locale_yml_copy
      copy_file('config/locales/blacklight.en.yml', 'config/locales/blacklight.en.yml', force: options[:force])
    end
  end
end
