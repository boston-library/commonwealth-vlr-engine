# frozen_string_literal: true

module CommonwealthVlrEngine
  module CollectionsHelperBehavior
    # link to view all items in a collection
    # @param document [SolrDocument] collection
    # @param class [String] CSS classes to add to the link
    def link_to_all_col_items(document, link_class: '')
      facet_params = { blacklight_config.collection_field => [document[blacklight_config.index.title_field.field]] }
      facet_params[blacklight_config.institution_field] = [document[blacklight_config.institution_field.to_sym]] if CommonwealthVlrEngine.config.dig(:institution, :pid).blank?
      search_params = { f: facet_params }
      search_params[:sort] = blacklight_config.date_asc_sort if document['destination_site_ssim'].to_s.include?('newspapers')
      link_to(t('blacklight.collections.browse.all'), search_catalog_path(search_params), class: link_class)
    end

    def hosted_collection_class(document)
      puts "DOCUMENT = #{document}"
      harvested_object?(document) ? 'harvested-collection' : 'hosted-collection'
    end
  end
end
