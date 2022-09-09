# frozen_string_literal: true

require 'rails_helper'

describe 'show audio player', js: true do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:5d86p086p')
  end

  it 'displays the audio player' do
    expect(page).to have_selector('#audio_player')
  end
end
