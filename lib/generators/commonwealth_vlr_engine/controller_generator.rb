# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class ControllerGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    argument :controller_name, type: :string, default: 'catalog'

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
      # TODO: remove, this line isn't in test app application_controller
      # remove_marker = "layout 'blacklight'"
      # gsub_file('app/controllers/application_controller.rb', remove_marker, '')
    end

    # Update the blacklight catalog controller
    # TODO: modify Blacklight::Gallery config rather than injecting
    # TODO: modify default BlacklightIiifSearch config rather than injecting
    # TODO: remove config.add_nav_action lines
    def inject_catalog_controller_behavior
      controller_path = "app/controllers/#{controller_name}_controller.rb"
      return if IO.read(controller_path).include?('CommonwealthVlrEngine')

      marker = 'include Blacklight::Catalog'
      insert_into_file controller_path, after: marker do
        %q(
  # CatalogController-scope behavior and configuration for CommonwealthVlrEngine
  include CommonwealthVlrEngine::ControllerOverride
)
      end

      marker = 'configure_blacklight do |config|'
      insert_into_file controller_path, after: marker do
        %q(
    # SearchBuilder contains logic for adding search params to Solr
    config.search_builder_class = CommonwealthSearchBuilder

    config.fetch_many_document_params = { fl: '*' }

    # TODO: figure out AdvancedSearch stuff
    # limit Advanced Search facets to this institution
    # can't call SearchBuilder.institution_limit because it's an instance method, not a class method
    # config.advanced_search[:form_solr_parameters]['fq'] = '+institution_ark_id_ssi:"' + CommonwealthVlrEngine.config[:institution][:pid] + '"'
)
      end

      # For config.default_solr_params
      gsub_file(controller_path, /config\.default_solr_params[\s\S]+?}/, '')

      fields_to_remove = [
          / +config.add_facet_field 'example_query_facet_field'[\s\S]+?}\n[ ]+}/,
          / +config.add_search_field\([\s\S]+?end/,
          / +config.index.title_field +=.+?$\n*/,
          / +config.index.display_type_field +=.+?$\n*/,
          / +config.add_facet_field +'.+?$\n*/,
          / +config.add_index_field +'.+?$\n*/,
          / +config.add_show_field +'.+?$\n*/,
          / +config.add_search_field +'.+?$\n*/,
          / +config.add_sort_field +'.+?$\n*/
      ]
      fields_to_remove.each do |remove_marker|
        gsub_file(controller_path, /#{remove_marker}/, '')
      end

      # modify show_document_actions
      gsub_file(controller_path, /:citation/, ":citation, partial: 'show_cite_tools'")
      gsub_file(controller_path, /:email,/, ":email, partial: 'show_email_tools', if: false,")
    end
  end
end
