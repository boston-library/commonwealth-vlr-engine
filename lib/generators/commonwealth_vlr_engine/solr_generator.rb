require 'rails/generators'

module CommonwealthVlrEngine
  class SolrGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "Copies Solr Templates to the internal test app for testing only"

    def copy_solr_files
      copy_file 'solr/conf/schema.xml', 'solr/conf/schema.xml', force: true
      copy_file 'solr/conf/solrconfig.xml', 'solr/conf/solrconfig.xml', force: true
    end
  end
end
