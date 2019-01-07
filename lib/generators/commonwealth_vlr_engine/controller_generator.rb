require 'rails/generators'

module CommonwealthVlrEngine
  class ControllerGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    argument     :controller_name  , type: :string , default: "catalog"

    desc """
  This generator makes the following changes to your application:
   1. Injects behavior into your user application_controller.rb
   2. Configures your catalog_controller.rb and removes many values.
  Thank you for Installing Commonwealth VLR.
         """

    # Add Commonwealth to the application controller
    def inject_application_controller_behavior
      unless IO.read("app/controllers/application_controller.rb").include?('CommonwealthVlrEngine::Controller')
        marker = 'include Blacklight::Controller'
        insert_into_file "app/controllers/application_controller.rb", :after => marker do
          %q{

  # adds some site-wide behavior into the application controller
  include CommonwealthVlrEngine::Controller
  layout 'commonwealth-vlr-engine'
  skip_after_action :discard_flash_if_xhr
}
        end
        remove_marker = "layout 'blacklight'"
        gsub_file("app/controllers/application_controller.rb", remove_marker, "")

      end
    end

    # Update the blacklight catalog controller
    def inject_catalog_controller_behavior
      unless IO.read("app/controllers/#{controller_name}_controller.rb").include?('CommonwealthVlrEngine')
        marker = 'include Blacklight::Catalog'
        insert_into_file "app/controllers/#{controller_name}_controller.rb", :after => marker do
          %q{
  # CatalogController-scope behavior and configuration for CommonwealthVlrEngine
  include CommonwealthVlrEngine::ControllerOverride
}
        end

        marker = 'configure_blacklight do |config|'
        insert_into_file "app/controllers/#{controller_name}_controller.rb", :after => marker do
          %q{
    # SearchBuilder contains logic for adding search params to Solr
    config.search_builder_class = CommonwealthSearchBuilder
    config.fetch_many_document_params = { fl: '*' }
    # limit Advanced Search facets to this institution
    # can't call SearchBuilder.institution_limit because it's an instance method, not a class method
    config.advanced_search[:form_solr_parameters]['fq'] = '+institution_pid_ssi:"' + CommonwealthVlrEngine.config[:institution][:pid] + '"'
}
        end

        #For config.default_solr_params
        gsub_file("app/controllers/#{controller_name}_controller.rb", /config\.default_solr_params[\s\S]+?}/, "")

        #For multi line fields
        fields_to_remove = [/ +config.add_facet_field 'example_query_facet_field'[\s\S]+?}\n[ ]+}/,
                                 / +config.add_search_field\([\s\S]+?end/
        ]

        fields_to_remove.each do |remove_marker|
          #gsub_file("app/controllers/#{controller_name}_controller.rb", /#{comment_marker}/, "\##{comment_marker}")
          gsub_file("app/controllers/#{controller_name}_controller.rb", /#{remove_marker}/, "")
        end

        #For single line fields
        fields_to_remove = [/ +config.index.title_field +=.+?$\n*/,
                                 / +config.index.display_type_field +=.+?$\n*/,
                                 / +config.add_facet_field +'.+?$\n*/,
                                 / +config.add_index_field +'.+?$\n*/,
                                 / +config.add_show_field +'.+?$\n*/,
                                 / +config.add_search_field +'.+?$\n*/,
                                 / +config.add_sort_field +'.+?$\n*/
        ]

        fields_to_remove.each do |remove_marker|
          #gsub_file("app/controllers/#{controller_name}_controller.rb", /#{comment_marker}/, "\##{comment_marker}")
          gsub_file("app/controllers/#{controller_name}_controller.rb", /#{remove_marker}/, "")
        end

      end

    end

  end
end
