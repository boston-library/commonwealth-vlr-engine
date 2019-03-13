require 'rails_helper'

describe IiifManifestController do

  render_views

  before(:each) do
    @item_ark = 'h702q6403'
    @item_pid = "bpl-dev:#{@item_ark}"
    @image_ark = 'h702q641c'
    @image_pid = "bpl-dev:#{@image_ark}"
  end

  describe 'get manifest' do

    before(:each) do
      get :manifest, params: {id: @item_pid}
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF manifest' do
      expect(response).to be_successful
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body["sequences"].length).to eq(1)
      expect(@response_body["sequences"].first["canvases"].length).to eq(2)
      expect(@response_body["sequences"].first["canvases"].first["images"].first["resource"]["@id"]).to have_content(@image_ark)
    end

  end

  describe 'get canvas' do

    before(:each) do
      get :canvas, params: {id:  @item_pid, canvas_object_id: @image_pid }
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF canvas' do
      expect(response).to be_successful
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body).to have_content("#{@item_ark}/canvas/#{@image_ark}")
      expect(@response_body["images"].length).to eq(1)
      expect(@response_body["images"].first["resource"]["@id"]).to have_content(@image_ark)
    end

  end

  describe 'get annotation' do

    before(:each) do
      get :annotation, params: {id:  @item_pid, annotation_object_id: @image_pid }
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF annotation' do
      expect(response).to be_successful
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body).to have_content("#{@item_ark}/annotation/#{@image_ark}")
      expect(@response_body["resource"]["@id"]).to have_content(@image_ark)
    end

  end

  describe 'get collection' do

    before(:each) do
      get :collection, params: {id: 'bpl-dev:3j334b469'}
      @response_body = JSON.parse(response.body)
    end

    it 'should render an IIIF Collection' do
      expect(response).to be_successful
      expect(@response_body).to have_content('http://iiif.io/api/presentation/2/context.json')
    end

    it 'should conform to the IIIF manifest spec' do
      expect(@response_body["@type"]).to eq('sc:Collection')
      expect(@response_body["manifests"].first["@id"]).to include('3j334603p')
    end

  end

  describe 'caching' do

    before(:each) do
      get :manifest, params: {id:  @item_pid }
      #post :cache_invalidate, :id => @item_pid
      #@response_body = JSON.parse(response.body)
    end

    it 'should cache the manifest' do
      expect(Rails.cache.exist?(@item_pid, { namespace: 'manifest' })).to be_truthy
    end

    describe 'cache_invalidate' do
      it 'should remove the cached manifest' do
        post :cache_invalidate, params: {:id => @item_pid}
        expect(JSON.parse(response.body)['result']).to be_truthy
        expect(Rails.cache.exist?(@item_pid, { namespace: 'manifest' })).to be_falsey
      end
    end

  end

end
