# monkey-patching Blacklight::Routes::RouteSets
# to use 'search' as path with Blacklight::CatalogController routes
# stopgap solution until patch can be submitted
# that will allow local app to provide :path option for resources passed as
# args to blacklight/lib/blacklight/rails/routes.rb#blacklight_for
module CommonwealthVlrEngine
  module RouteSets

    extend ActiveSupport::Concern
    included do

      def map_resource(key)
        add_routes do |options|
          get "search/facet/:id", :to => "#{key}#facet", :as => "#{key}_facet"
          get "search", :to => "#{key}#index", :as => "#{key}_index"
        end
      end

      def export(primary_resource)
        add_routes do |options|
          get "search/opensearch", :to => "#{primary_resource}#opensearch", :as => "opensearch_#{primary_resource}"
          get "search/citation", :to => "#{primary_resource}#citation", :as => "citation_#{primary_resource}"
          match 'search/email', :to => "#{primary_resource}#email", :as => "email_#{primary_resource}", :via => [:get, :post]
        end
      end

      def solr_document(primary_resource)
        add_routes do |options|

          args = {only: [:show]}
          args[:constraints] = options[:constraints] if options[:constraints]

          resources :solr_document, args.merge(path: "search", controller: primary_resource) do
            member do
              post "track"
            end
          end

          # :show and :update are for backwards-compatibility with catalog_url named routes
          resources primary_resource, args
        end
      end

    end

  end

end
Blacklight::Routes::RouteSets.send(:include, CommonwealthVlrEngine::RouteSets)