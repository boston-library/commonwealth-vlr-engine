module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  include CommonwealthVlrEngine::SearchHistoryConstraintsHelperBehavior
  include CommonwealthVlrEngine::RenderConstraintsHelperBehavior
  include CommonwealthVlrEngine::CatalogHelperBehavior
end
