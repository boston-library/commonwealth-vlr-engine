# frozen_string_literal: true

class SavedSearchesController < ApplicationController
  include Bpluser::SavedSearches

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper BlacklightMaps::RenderConstraintsOverride
  helper BlacklightRangeLimit::ViewHelperOverride
  helper RangeLimitHelper
  helper CommonwealthVlrEngine::RenderConstraintsHelperBehavior
end