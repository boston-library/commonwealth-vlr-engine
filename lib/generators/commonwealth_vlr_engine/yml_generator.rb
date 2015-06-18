require 'rails/generators'

module CommonwealthVlrEngine
  class YmlGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc 'YmlGenerator Commonwealth VLR Engine'

    def config_yml_copy
      copy_file 'solr.yml.sample', 'config/solr.yml' unless IO.read('config/solr.yml').present?
      copy_file 'geojson_static_file.yml.sample', 'config/geojson_static_file.yml' unless IO.read('config/geojson_static_file.yml').present?
      copy_file 'google_analytics.yml.sample', 'config/google_analytics.yml' unless IO.read('config/google_analytics.yml').present?
      copy_file 'contact_emails.yml.sample', 'config/contact_emails.yml' unless IO.read('config/contact_emails.yml').present?
      copy_file 'predicate_mappings.yml', 'config/predicate_mappings.yml' unless IO.read('config/predicate_mappings.yml').present?
      copy_file 'fedora.yml.sample', 'config/fedora.yml' unless IO.read('config/fedora.yml').present?
      copy_file 'iiif_server.yml.sample', 'config/iiif_server.yml' unless IO.read('config/iiif_server.yml').present?
      copy_file 'omniauth-facebook.yml.sample', 'config/omniauth-facebook.yml' unless IO.read('config/omniauth-facebook.yml').present?
      copy_file 'omniauth-polaris.yml.sample', 'config/omniauth-polaris.yml' unless IO.read('config/omniauth-polaris.yml').present?
      copy_file 'vlr.yml', 'vlr.yml' unless IO.read('config/vlr.yml').present?
    end

    def locale_yml_copy
      copy_file 'blacklight.en.yml', 'config/locales/blacklight.en.yml'
      copy_file 'devise.en.yml', 'config/locales/devise.en.yml'
    end

  end
end