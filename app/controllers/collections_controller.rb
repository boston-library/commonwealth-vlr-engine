class CollectionsController < CatalogController
  include CommonwealthVlrEngine::CollectionsControllerBehavior

  # Blacklight uses #search_action_url to figure out the right URL for
  # the global search box
  # Should be moved to the behavior but that gives me problems since this registered to the helper...
  def search_action_url options = {}
    search_catalog_url(options.except(:controller, :action))
  end
  helper_method :search_action_url

  # find a representative image/item for a series
  # Should be moved to the behavior but that gives me problems since this registered to the helper...
  def get_series_image_obj(series_title,collection_title)
    blacklight_config.search_builder_class = CommonwealthFlaggedSearchBuilder # ignore flagged items
    series_doc_list = search_results({f: {'related_item_series_ssim' => series_title,
                                          blacklight_config.collection_field => collection_title},
                                      rows: 1})[1]
    series_doc_list.first
  end
  helper_method :get_series_image_obj
end
