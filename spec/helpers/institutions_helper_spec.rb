# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:institution) { SolrDocument.find('bpl-dev:abcd12345') }

  before :each do
    without_partial_double_verification do
      allow(helper).to receive_messages(blacklight_config: blacklight_config)
    end
  end

  describe '#link_to_all_inst_items' do
    before(:each) { assign(:institution_title, 'Foo Institution') }

    it 'creates a search link with the correct institution params' do
      expect(helper.link_to_all_inst_items('foo')).to include("#{blacklight_config.institution_field}%5D%5B%5D=Foo+Institution")
    end
  end
end
