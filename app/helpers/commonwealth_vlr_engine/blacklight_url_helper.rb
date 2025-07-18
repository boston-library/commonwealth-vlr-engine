# frozen_string_literal: true

module CommonwealthVlrEngine
  module BlacklightUrlHelper
    include Blacklight::UrlHelperBehavior

    # need this method for rss and atom polymorphic_url(url_for_document(document))
    # because polymorphic_url appends any action passed in arg hash to route
    # so we need to re-route to the correct url
    # or we get "undefined method `show_solr_document_url' for #<ActionView::Base"
    # from Blacklight::DocumentPresenter#link_rel_alternates
    def show_solr_document_url(doc, options)
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

    # don't add session tracking to links when displaying items on certain non-catalog#* views
    def session_tracking_path(document, params = {})
      notrack_controllers = %w(institutions collections primary_source_sets pages)
      return if notrack_controllers.include?(controller_name)

      super
    end
  end
end
