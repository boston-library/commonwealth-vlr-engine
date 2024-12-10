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
          1. Adds commonwealth_search_builder.rb to app/models"

    def inject_search_builder_behavior
      copy_file 'commonwealth_search_builder.rb', 'app/models/commonwealth_search_builder.rb'
    end

    # add params needed for IIIF content search
    def modify_iiif_search_builder
      iiif_sb_path = "app/models/iiif_search_builder.rb"
      return if IO.read(iiif_sb_path).include?('solr_parameters[:qf]')

      marker = 'def ocr_search_params(solr_parameters = {})'
      insert_into_file iiif_sb_path, after: marker do
        %q(
    solr_parameters[:qf] = '${fulltext_qf}'
    solr_parameters[:pf] = '${fulltext_pf}')
      end
    end

    # Setup the database migrations
    def copy_migrations
      rake 'railties:install:migrations'
    end
  end
end
