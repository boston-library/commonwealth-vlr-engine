require 'rails/generators'

module CommonwealthVlrEngine
  class ControllerGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    argument     :controller_name  , type: :string , default: "catalog"

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
    def inject_catalog_controller_behavior
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

        gsub_file("app/controllers/#{controller_name}_controller.rb", /config\.default_solr_params[\s\S]+?}/, "")
        fields_to_comment_out = ['config.index.title_field',
                             'config.index.display_type_field',
                             'config.add_facet_field',
                             'config.add_index_field',
                             'config.add_show_field',
                             'config.add_search_field',
                             'config.add_sort_field'
        ]

        fields_to_comment_out.each do |comment_marker|
          insert_into_file "app/controllers/#{controller_name}_controller.rb", :before => comment_marker do
            %q{#}
          end
        end
      end

    end

  end
end