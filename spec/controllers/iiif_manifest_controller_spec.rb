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

end