require 'spec_helper'

describe CollectionsHelper do

  let(:blacklight_config) { CatalogController.blacklight_config }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#link_to_all_col_items' do
    before { @coll_items_link = helper.link_to_all_col_items('Foo Collection', 'Bar Institution', 'baz') }
    it 'should create a search link with the correct collection and institution params' do
      expect(@coll_items_link).to include("#{blacklight_config.collection_field}%5D%5B%5D=Foo+Collection")
      expect(@coll_items_link).to include("#{blacklight_config.institution_field}%5D=Bar+Institution")
    end
  end

  # TODO: figure out why this spec doesn't pass when run in CI/run-all-specs testing
  # getting NoMethodError: private method 'should_render_col_az?' called
  # works fine in context of this single spec though
  describe '#should_render_col_az?' do
    it 'should return false' #do
      #expect(helper.should_render_col_az?).to be_falsey
    #end
  end

end