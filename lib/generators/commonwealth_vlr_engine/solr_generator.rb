# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class SolrGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'Copies Solr Templates to the internal test app for testing only'

    def copy_solr_files
      copy_file 'solr/conf/schema.xml', 'solr/conf/schema.xml', force: true
      copy_file 'solr/conf/solrconfig.xml', 'solr/conf/solrconfig.xml', force: true
    end

    def set_solr_version
      vlr_solr_wrapper = YAML.safe_load(File.open(File.join(File.join(CommonwealthVlrEngine.root, '.solr_wrapper.yml'))))
      marker = '# port: 8983'
      insert_into_file '.solr_wrapper.yml', after: marker do
        %Q[
version: #{vlr_solr_wrapper['version']}
instance_dir: tmp/solr]
      end
    end
  end
end
