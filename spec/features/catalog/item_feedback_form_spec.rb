# frozen_string_literal: true

require 'rails_helper'

describe 'item feedback modal', js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:df65v790j')
  end

  it 'displays the item feedback link when the page is loaded' do
    expect(page).to have_selector('#itemFeedbackLink')
  end

  it 'renders the modal popup when the button is clicked' do
    click_link('itemFeedbackLink')
    expect(page).to have_selector('#item_feedback_form')
  end
end
