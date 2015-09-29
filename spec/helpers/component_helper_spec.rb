require 'spec_helper'

describe ComponentHelper do

  include Blacklight::SearchHelper

  let(:document) { Blacklight.default_index.search({:q => 'id:"bpl-dev:h702q6403"', :rows => 1}).documents.first }

  before(:each) do
    allow(helper).to receive(:has_user_authentication_provider?).and_return(true)
    allow(helper).to receive(:current_or_guest_user).and_return(true)
    allow(helper).to receive(:current_user).and_return(User.create!({:email => "testy@test.com", :password => "password"}))
    @current_bookmarks = [] # have to set this for Blacklight::CatalogHelperBehavior#current_bookmarks
  end

  describe '#render_show_doc_actions' do

    before { @show_doc_actions = helper.render_show_doc_actions(document, {}) }

    it 'should create the document actions controls wrapper' do
      expect(@show_doc_actions).to include('<div class="documentFunctions">')
    end

    it 'should include the catalog/add_this partial' do
      expect(@show_doc_actions).to include('addthis')
    end

    it 'should include the catalog/folder_item_control partial' do
      expect(@show_doc_actions).to include('<div id="folder_item_toggle">')
    end

  end

end