# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController do
  render_views

  describe "GET 'home'" do
    before(:each) do
      CarouselSlide.create(context: 'root', image_pid: 'bpl-dev:000000043',
                           institution: 'Boston Public Library', object_pid: 'bpl-dev:00000003t',
                           region: 'pct:10,20,80,23', size: '1600,', title: "Map of the county of Norfolk, Massachusetts")
      get :home
    end

    it 'responds to the #home action' do
      expect(response).to be_successful
      expect(assigns(:banner_image)).to_not be_nil
    end

    it 'renders the home page' do
      expect(response.body).to have_selector('#home_about')
    end
  end

  describe "GET 'about_site'" do
    it 'renders the the #about_site action' do
      get :about_site
      expect(response).to be_successful
      expect(assigns(:nav_li_active)).to_not be_nil
      expect(response.body).to have_selector('.about_content')
    end
  end
end
