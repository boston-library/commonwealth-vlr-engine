require 'rails/generators'

module CommonwealthVlrEngine
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    argument :search_builder_name, type: :string , default: "search_builder"
    argument :document_name, type: :string , default: "solr_document"
    argument :controller_name, type: :string , default: "catalog"

    desc "InstallGenerator Commonwealth VLR Engine"

    def insert_to_assets
      generate "commonwealthvlr:assets"
    end

    def insert_to_controllers
      generate "commonwealthvlr:controller", controller_name
    end

    def insert_to_models
      generate "commonwealthvlr:model", search_builder_name, document_name
    end
  end
end