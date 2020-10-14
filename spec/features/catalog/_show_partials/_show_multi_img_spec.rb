require 'rails_helper'

describe 'multi image viewer' do
  before(:each) do
    visit solr_document_path(id: 'bpl-dev:h702q6403')
    click_link('carousel-control_next')
  end

  it 'displays the next image when a prev-next link is clicked' do
    expect(find('.img_show')['src']).to match /bpl-dev:h702q642n/
  end

  it 'should update the thumbnail in the #thumbnail_list' do
    expect(all('#thumbnail_list li').last).to have_selector('.in_viewer')
  end
end
