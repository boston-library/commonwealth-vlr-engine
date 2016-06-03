module CommonwealthVlrEngine
  module BlacklightUrlHelper
    include Blacklight::UrlHelperBehavior

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
    # this uses the older BL 5.14 def as the basis, but don't really need to update to BL6.* model
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
