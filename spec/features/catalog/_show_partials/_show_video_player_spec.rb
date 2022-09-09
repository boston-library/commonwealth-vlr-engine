# frozen_string_literal: true

require 'rails_helper'

describe 'show video player' do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:cj82k894f')
  end

  it 'displays the video player' do
    expect(page).to have_selector('#video_player')
  end
end
