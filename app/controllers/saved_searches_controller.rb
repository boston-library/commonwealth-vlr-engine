# frozen_string_literal: true
class SavedSearchesController < ApplicationController
  include Blacklight::SavedSearches

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper BlacklightMaps::RenderConstraintsOverride
  helper CommonwealthVlrEngine::RenderConstraintsOverride
end