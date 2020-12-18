# frozen_string_literal: true

require 'rails_helper'

describe 'a-z links' do
  before(:all) do
    CommonwealthVlrEngine::CollectionsHelperBehavior.module_eval do
      # set this helper to return true so AZ links are rendered
      def should_render_col_az?
        true
      end
    end
  end

  after(:all) do
    CommonwealthVlrEngine::CollectionsHelperBehavior.module_eval do
      def should_render_col_az?
        false
      end
    end
  end

  it 'shows the a-z links' do
    visit collections_path
    within('.item_az_links') do
      expect(page).to have_selector('.az_link')
    end
  end

  it 'shows correct results after clicking a letter link' do
    visit collections_path
    within('.item_az_links') do
      click_link('C')
    end
    expect(page).to have_selector('.document-title-heading', :text => 'Carte de Visite Collection')
  end
end
