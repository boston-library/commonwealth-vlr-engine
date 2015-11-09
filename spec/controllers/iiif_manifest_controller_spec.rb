require 'spec_helper'

describe IiifManifestController do

  render_views

  describe 'get manifest' do

    before(:each) do
      get :manifest, :id => 'bpl-dev:h702q6403'
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF manifest' do
      expect(response).to be_success
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body["sequences"].length).to eq(1)
      expect(@response_body["sequences"].first["canvases"].length).to eq(2)
      expect(@response_body["sequences"].first["canvases"].first["images"].first["resource"]["@id"]).to have_content('h702q641c')
    end

  end

  describe 'get canvas' do

    before(:each) do
      get :canvas, :id => 'bpl-dev:h702q6403', :canvas_object_id => 'bpl-dev:h702q641c'
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF canvas' do
      expect(response).to be_success
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body).to have_content('h702q6403/canvas/h702q641c')
      expect(@response_body["images"].length).to eq(1)
      expect(@response_body["images"].first["resource"]["@id"]).to have_content('h702q641c')
    end

  end

  describe 'get annotation' do

    before(:each) do
      get :annotation, :id => 'bpl-dev:h702q6403', :annotation_object_id => 'bpl-dev:h702q641c'
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF annotation' do
      expect(response).to be_success
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body).to have_content('h702q6403/annotation/h702q641c')
      expect(@response_body["resource"]["@id"]).to have_content('h702q641c')
    end

  end

  describe 'get collection' do

    before(:each) do
      get :collection, :id => 'bpl-dev:TK'
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF Collection' do
      expect(response).to be_success
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body["resource"]["@id"]).to have_content('TK')
      expect(@response_body["manifests"].first["@id"]).to include('TK')
    end

  end

end