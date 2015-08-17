module CommonwealthVlrEngine
  module BlacklightUrlHelper
    include Blacklight::UrlHelperBehavior

    # overriding to allow use in collections#show and institutions#show
    # so facet links in those views point to catalog#index
    def add_facet_params_and_redirect(field, item)
      new_params = add_facet_params(field, item)

      # Delete any request params from facet-specific action, needed
      # to redir to index action properly.
      request_keys = blacklight_config.facet_paginator_class.request_keys
      new_params.except! *request_keys.values

      # Force controller#action to be catalog#index.
      new_params[:action] = "index"
      new_params[:controller] = "catalog"
      new_params
    end

    # need this method for rss and atom polymorphic_url(url_for_document(document))
    # because polymorphic_url appends any action passed in arg hash to route
    # so we need to re-route to the correct url
    def show_solr_document_url doc, options
      if options[:controller]
        case options[:controller]
          when 'collections'
            collection_url doc
          when 'institutions'
            institution_url doc
        end
      else
        solr_document_url doc, options
      end

    end

    # override to route to collections#show and institutions#show where appropriate
    def url_for_document doc, options = {}
      if respond_to?(:blacklight_config) && doc.respond_to?(:[])
        display_type = doc[blacklight_config.show.display_type_field].presence
        if display_type == 'Collection' || display_type == 'Institution'
          {controller: display_type.downcase.pluralize, action: :show, id: doc}
        else
          doc
        end
      else
        doc
      end
    end

  end
end
