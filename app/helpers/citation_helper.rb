# frozen_string_literal: true

# helper methods for rendering citations
module CitationHelper
  # an array of available citation formats
  # should be a "render_#{style}_citation" method for each in CommonwealthVlrEngine::Document::CitationComponent
  def citation_styles
    %w(mla apa chicago wikipedia)
  end
end
