require 'rails_helper'

describe CollectionsHelper do

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:image_pid) { 'bpl-dev:h702q641c' }

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

  describe '#render_collection_image' do
    before do
      assign(:collection_image_pid, image_pid)
      assign(:collection_image_info, { pid: image_pid, title: 'foo', access_master: true })
    end

    # TODO: this spec should probably be more descriptive
    # punting for now since:
    # (1) 'should_receive' is deprecated and not able to figure out replacement
    # (2) not sure that testing rendering partial is even appropriate, might be better as view spec
    it 'should render the correct partial' do
      expect(helper).to receive(:render)
      helper.render_collection_image
    end
  end

  describe '#collection_image_url' do
    it 'should return the correct url' do
      col_img_url = helper.collection_image_url(image_pid)
      expect(col_img_url).to eq("#{IIIF_SERVER['url']}#{image_pid}/full/600,/0/default.jpg")
    end
  end

  # TODO: figure out why this spec doesn't pass when run in CI/run-all-specs testing
  # getting NoMethodError: private method 'should_render_col_az?' called
  # works fine in context of this single spec though
  describe '#should_render_col_az?' do
    it 'should return false' do
      expect(helper.should_render_col_az?).to be_falsey
    end
  end

end
