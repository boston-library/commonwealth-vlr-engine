require 'spec_helper'

describe OaiItemHelper do

  include Blacklight::SearchHelper

  class OaiItemHelperTestClass < CatalogController
    cattr_accessor :blacklight_config

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::Finder

    def initialize blacklight_config
      self.blacklight_config = blacklight_config
    end

  end

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:oai_item_helper_test_class) { OaiItemHelperTestClass.new blacklight_config }
  let(:document) { Blacklight.default_index.search({:q => "id:\"bpl-dev:h702q6403\"", :rows => 1}).documents.first }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#oai_inst_name' do
    it 'should return the institution name' do
      expect(helper.oai_inst_name(document)).to eq('Boston Public Library')
    end
  end

  describe '#oai_link_text' do
    it 'should return the correct link text' do
      expect(helper.oai_link_text(document)).to include('View the full image')
    end
  end

end
