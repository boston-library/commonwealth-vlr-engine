# frozen_string_literal: true

class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory
  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  # helper BlacklightMaps::RenderConstraintsOverride
  helper BlacklightRangeLimit::ViewHelperOverride
  helper RangeLimitHelper
  helper CommonwealthVlrEngine::RenderConstraintsHelperBehavior
end
