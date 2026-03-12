# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'advanced search accessibility', js: true do
  it 'should be accessible' do
    visit blacklight_advanced_search_engine.advanced_search_path
    expect(page).to be_axe_clean
  end
end
