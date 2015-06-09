require 'rails/generators'

module CommonwealthVlrEngine
  class ModelGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    argument     :search_builder_model, :type => :string , :default => "search_builder"
    argument     :document_model_name, :type => :string , :default => "solr_document"

    desc """
  This generator makes the following changes to your application:
   1. Injects the institution limiter into search_builder.rb
   2. Adds OpenSeadragon suppoer to solr_document.rb
  Thank you for Installing Commonwealth VLR.
         """

    # Limit the institutions
    def inject_search_builder_behavior
      unless IO.read("app/models/#{search_builder_model}.rb").include?('def institutions_filter')
        marker = 'Blacklight::Solr::SearchBuilderBehavior'
        insert_into_file "app/models/#{search_builder_model}.rb", :after => marker do
          %q{

  # limit to a specific institution
  def institution_limit(solr_parameters = {})
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '+institution_pid_ssi:"' + CommonwealthVlrEngine.config[:institution][:pid] + '"'
  end
}
        end
      end
    end

    # OpenSeadragon support?
    def inject_solr_document_behavior
      unless IO.read("app/models/#{document_model_name}.rb").include?('Blacklight::Gallery::OpenseadragonSolrDocument')
        marker = 'include Blacklight::Solr::Document'
        insert_into_file "app/models/#{document_model_name}.rb", :after => marker do
          %q{

  include Blacklight::Gallery::OpenseadragonSolrDocument
}
        end
      end
    end

  end
end