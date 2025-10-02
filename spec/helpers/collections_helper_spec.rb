# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:document) do
    { blacklight_config.index.title_field.field => 'Foo Collection',
      blacklight_config.institution_field.to_sym => 'Bar Institution',
      blacklight_config.hosting_status_field.to_sym => 'harvested' }
  end

  before(:each) do
    without_partial_double_verification do
      allow(helper).to receive_messages(blacklight_config: blacklight_config)
    end
  end

  describe '#link_to_all_col_items' do
    let(:coll_items_link) do
      helper.link_to_all_col_items(document, link_class: 'baz')
    end
    it 'creates a search link with the correct collection and institution params' do
      expect(coll_items_link).to include("#{blacklight_config.collection_field}%5D%5B%5D=Foo+Collection")
      expect(coll_items_link).to include("#{blacklight_config.institution_field}%5D%5B%5D=Bar+Institution")
    end
  end

  describe '#hosted_collection_class' do
    it 'returns the correct collection class' do
      expect(helper.hosted_collection_class(document)).to eq('harvested-collection')
    end
  end
end
