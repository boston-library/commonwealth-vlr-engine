# frozen_string_literal: true

require 'rails_helper'

describe 'flagged item warning' do
  it 'displays the flagged item warning' do
    visit solr_document_path(id: 'bpl-dev:g445cd14k')
    expect(page).to have_selector('#flagged_content_warning')
  end
end
