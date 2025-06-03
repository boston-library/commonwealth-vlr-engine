# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class ControllerGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    CATALOG_CONTROLLER_PATH = 'app/controllers/catalog_controller.rb'

    desc "This generator makes the following changes to your application:
          1. Injects behavior into your user application_controller.rb
          2. Configures your catalog_controller.rb and removes many values."

    # Add Commonwealth to the application controller
    def inject_application_controller_behavior
      return if IO.read('app/controllers/application_controller.rb').include?('CommonwealthVlrEngine::Controller')

      marker = 'include Blacklight::Controller'
      insert_into_file 'app/controllers/application_controller.rb', after: marker do
        %q(

  # adds some site-wide behavior into the application controller
  include CommonwealthVlrEngine::Controller
)
      end
    end

    # Update the blacklight catalog controller
    def inject_catalog_controller_behavior
      return if IO.read(CATALOG_CONTROLLER_PATH).include?('CommonwealthVlrEngine')

      marker = 'include Blacklight::Catalog'
      insert_into_file CATALOG_CONTROLLER_PATH, after: marker do
        %q(
  # CatalogController-scope behavior and configuration for CommonwealthVlrEngine
  include CommonwealthVlrEngine::ControllerOverride
)
      end
    end

    # updates to stuff within configure_blacklight block
    # TODO: modify default Blacklight::Gallery config rather than injecting
    # TODO: remove config.add_nav_action lines
    def modify_blacklight_config
      marker = 'configure_blacklight do |config|'
      insert_into_file CATALOG_CONTROLLER_PATH, after: marker do
        %q(
    # SearchBuilder contains logic for adding search params to Solr
    config.search_builder_class = CommonwealthSearchBuilder

    config.fetch_many_document_params = { fl: '*' }

    # limit Advanced Search facets to this institution (uncomment if needed)
    # can't call SearchBuilder.institution_limit because it's an instance method, not a class method
    # config.advanced_search[:form_solr_parameters]['fq'] = '+institution_ark_id_ssi:"' + CommonwealthVlrEngine.config[:institution][:pid] + '"'
)
      end

      # For config.default_solr_params
      gsub_file(CATALOG_CONTROLLER_PATH, /config\.default_solr_params[\s\S]+?}/, '')

      # remove default blacklight index/facet/show/search/sort fields
      fields_to_remove = [
        / +config.add_facet_field 'example_query_facet_field'[\s\S]+?}\n[ ]+}/,
        / +config.add_search_field\([\s\S]+?end/,
        / +config.index.title_field +=.+?$\n*/,
        / +config.index.display_type_field +=.+?$\n*/,
        / +config.add_facet_field +'.+?$\n*/,
        / +config.add_index_field +'.+?$\n*/,
        / +config.add_show_field +'.+?$\n*/,
        / +config.add_search_field +'.+?$\n*/,
        / +config.add_sort_field +'.+?$\n*/,
        / +config.add_show_tools_partial\(.+?$\n*/
      ]
      fields_to_remove.each do |remove_marker|
        gsub_file(CATALOG_CONTROLLER_PATH, /#{remove_marker}/, '')
      end

      # update blacklight_iiif_search config
      gsub_file(CATALOG_CONTROLLER_PATH, / +config.iiif_search[\s\S]+}/) do
        %q(    config.iiif_search = {
      full_text_field: 'ocr_tsiv',
      object_relation_field: 'is_file_set_of_ssim',
      page_model_field: 'curator_model_suffix_ssi',
      supported_params: %w(q page)
    })
      end

      # modify Blacklight::Gallery config
      gsub_file(CATALOG_CONTROLLER_PATH, /config.view.slideshow/, '# config.view.slideshow')
      gsub_file(CATALOG_CONTROLLER_PATH, /config.show.tile_source_field/, '# config.show.tile_source_field')
      gsub_file(CATALOG_CONTROLLER_PATH, /config.show.partials \|\|= \[\]/, '# config.show.partials ||= []')
      gsub_file(CATALOG_CONTROLLER_PATH, /config.show.partials.insert/, '# config.show.partials.insert')
    end
  end
end
