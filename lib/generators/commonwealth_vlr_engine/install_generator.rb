require 'rails/generators'

module CommonwealthVlrEngine
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    argument :search_builder_name, type: :string , default: "search_builder"
    argument :document_name, type: :string , default: "solr_document"
    argument :controller_name, type: :string , default: "catalog"

    desc "InstallGenerator Commonwealth VLR Engine"

    def verify_blacklight_installed
      if !IO.read("app/controllers/application_controller.rb").include?('include Blacklight::Controller')
         raise "It doesn't look like you have Blacklight installed..."
      end
    end

    def insert_to_assets
      generate "commonwealth_vlr_engine:assets"
    end

    def insert_to_controllers
      generate "commonwealth_vlr_engine:controller", controller_name
    end

    def insert_to_models
      generate "commonwealth_vlr_engine:model", search_builder_name, document_name
    end
  end
end