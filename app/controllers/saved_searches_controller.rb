# frozen_string_literal: true

class SavedSearchesController < ApplicationController
  include CommonwealthVlrEngine::SavedSearches

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper BlacklightMaps::RenderConstraintsOverride
  helper BlacklightRangeLimit::ViewHelperOverride
  helper RangeLimitHelper
  helper CommonwealthVlrEngine::RenderConstraintsOverride
end