# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

module CommonwealthVlrEngine
  class ModelGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    argument     :search_builder_model, type: :string, default: 'search_builder'
    argument     :document_model_name, type: :string, default: 'solr_document'

    desc "This generator makes the following changes to your application:
          1. Adds commonwealth_search_builder.rb to app/models
          2. Adds OpenSeadragon support to solr_document.rb"

    def inject_search_builder_behavior
      copy_file 'commonwealth_search_builder.rb', 'app/models/commonwealth_search_builder.rb'
      copy_file File.join(BlacklightIiifSearch.root, 'lib', 'generators', 'blacklight_iiif_search', 'templates', 'iiif_search_builder.rb'),
                'app/models/iiif_search_builder.rb'
    end

    # OpenSeadragon support?
    def inject_solr_document_behavior
      return if IO.read("app/models/#{document_model_name}.rb").include?('Blacklight::Gallery::OpenseadragonSolrDocument')

      marker = 'include Blacklight::Solr::Document'
      insert_into_file "app/models/#{document_model_name}.rb", after: marker do
        "\n  include Blacklight::Gallery::OpenseadragonSolrDocument"
      end
    end

    # Setup the database migrations
    def copy_migrations
      rake 'railties:install:migrations'
    end
  end
end
