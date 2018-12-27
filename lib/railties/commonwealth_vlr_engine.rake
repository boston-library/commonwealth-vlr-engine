namespace :commonwealth_vlr_engine do
  namespace :test_index do
    desc 'Put sample data into test app solr'
    task :seed => :environment do
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
