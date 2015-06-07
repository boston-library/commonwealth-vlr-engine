require 'rails/generators'

module CommonwealthVlrEngine
  class ControllerGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    COMMENT_OUT_ARRAY = ['config.default_solr_params',
                     'config.index.title_field',
                     'config.index.display_type_field',
                     'config.add_facet_field',
                     'config.add_index_field',
                     'config.add_show_field',
                     'config.add_search_field',
                     'config.add_sort_field'
                    ]

    desc """
  This generator makes the following changes to your application:
   1. Injects behavior into your user application_controller.rb
   2. Configures your catalog_controller.rb.
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
}
        end
      end
    end

    # Update the blacklight catalog controller
    def injest_catalog_controller_behavior
      template "catalog_controller.rb", "app/controllers/#{controller_name}_controller.rb"

      unless IO.read("app/controllers/#{controller_name}_controller.rb").include?('CommonwealthVlrEngine')
        marker = 'include Blacklight::Catalog'
        insert_into_file "app/controllers/#{controller_name}_controller.rb", :after => marker do
          %q{
  # CatalogController-scope behavior and configuration for CommonwealthVlrEngine
  include CommonwealthVlrEngine::ControllerOverride
  CatalogController.search_params_logic += [:instituition_limit]
}
        end

        marker = 'configure_blacklight do |config|'
        insert_into_file "app/controllers/#{controller_name}_controller.rb", :after => marker do
          %q{
    # SearchBuilder contains logic for adding search params to Solr
    config.search_builder_class = SearchBuilder
}
        end

        COMMENT_OUT_ARRAY.each do |marker|
          insert_into_file "app/controllers/#{controller_name}_controller.rb", :after => marker do
            '//'
          end
        end
      end

    end

  end
end