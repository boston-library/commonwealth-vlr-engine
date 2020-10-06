require 'rails_helper'

describe CarouselSlide do

  before(:each) do
    @slide_attr = {
      :sequence => 1,
      :object_pid => 'bpl-dev:123456',
      :image_pid => 'bpl-dev:7891011',
      :size => '570,',
      :region => '250,90,295,570',
      :title => 'The Slide Title',
      :institution => 'Institution Name',
      :context => 'bpl-dev:0022331'
    }
  end

  it 'creates a new slide given valid attributes' do
    CarouselSlide.create!(@slide_attr)
  end

  describe 'assign values properly' do

    before(:each) do
      @slide = CarouselSlide.create!(@slide_attr)
    end

    it 'has a title attribute' do
      expect(@slide).to respond_to(:title)
    end

    it 'has the right title' do
      expect(@slide.title).to eq('The Slide Title')
    end

  end

end
