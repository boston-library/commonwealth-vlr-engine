# frozen_string_literal: true

require 'rails_helper'

describe CollectionsHelper, :vcr do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:image_pid) { 'bpl-dev:h702q641c' }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#link_to_all_col_items' do
    let(:coll_items_link) do
      helper.link_to_all_col_items('Foo Collection', 'Bar Institution', 'baz')
    end
    it 'creates a search link with the correct collection and institution params' do
      expect(coll_items_link).to include("#{blacklight_config.collection_field}%5D%5B%5D=Foo+Collection")
      expect(coll_items_link).to include("#{blacklight_config.institution_field}%5D=Bar+Institution")
    end
  end

  describe '#render_collection_image' do
    before(:each) do
      assign(:collection_image_info,
             { pid: 'bpl-dev:h702q6403', image_pid: image_pid, title: 'foo', access_master: true })
    end

    it 'renders the correct partial' do
      allow(helper).to receive(:render).and_call_original
      helper.render_collection_image
      expect(helper).to have_received(:render)
    end
  end

  describe '#collection_image_url' do
    it 'returns the correct url' do
      col_img_url = helper.collection_image_url(image_pid)
      expect(col_img_url).to eq("#{IIIF_SERVER['url']}#{image_pid}/0,952,1496,544/1100,/0/default.jpg")
    end
  end

  describe '#should_render_col_az?' do
    it 'returns false by default' do
      expect(helper.should_render_col_az?).to be_falsey
    end
  end
end
