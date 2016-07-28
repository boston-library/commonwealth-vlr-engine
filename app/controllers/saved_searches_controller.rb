# frozen_string_literal: true
class SavedSearchesController < ApplicationController
  include Blacklight::SavedSearches

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper BlacklightMaps::RenderConstraintsOverride
  helper BlacklightRangeLimit::ViewHelperOverride
  helper RangeLimitHelper
  helper CommonwealthVlrEngine::RenderConstraintsOverride
end