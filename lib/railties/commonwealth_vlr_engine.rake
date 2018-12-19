#require 'rails/generators'
#require 'generators/commonwealth_vlr_engine/install_generator'

namespace :commonwealth_vlr_engine do
  desc "Put sample data into test app solr"
  namespace :test_index do
    task :seed do
      require 'yaml'
      docs = YAML.safe_load(File.open(File.join(File.join(CommonwealthVlrEngine.root,
                                                          'spec',
                                                          'fixtures',
                                                          'sample_solr_documents.yml'))))
      conn = Blacklight.default_index.connection
      conn.add docs
      conn.commit
    end
  end
end
