# frozen_string_literal: true

require 'rails_helper'

describe PagesController do
  render_views

  describe "GET 'home'" do
    before(:each) { get :home }

    it 'responds to the #home action' do
      expect(response).to be_successful
      expect(assigns(:carousel_slides)).to_not be_nil
    end

    it 'renders the home page' do
      expect(response.body).to have_selector('#content_home')
    end
  end

  describe "GET 'about'" do
    it 'renders the the #about action' do
      get :about
      expect(response).to be_successful
      expect(assigns(:nav_li_active)).to_not be_nil
      expect(response.body).to have_selector('.about_content')
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

  describe "GET 'explore'" do
    it 'renders the the #explore action' do
      get :explore
      expect(response).to be_successful
      expect(assigns(:nav_li_active)).to_not be_nil
      expect(response.body).to have_selector('.explore_content')
    end
  end
end
