class InstitutionsController < CatalogController
  include CommonwealthVlrEngine::InstitutionsControllerBehavior

  # Blacklight uses #search_action_url to figure out the right URL for
  # the global search box
  # Should be moved to the behavior but that gives me problems since this registered to the helper...
  def search_action_url options = {}
    search_catalog_url(options.except(:controller, :action))
  end
  helper_method :search_action_url
end