# Meant to be applied on top of CatalogController to override some instance methods
module CommonwealthVlrEngine
  module BlacklightOverride
    def render_bookmarks_control?
      false
    end
  end
end