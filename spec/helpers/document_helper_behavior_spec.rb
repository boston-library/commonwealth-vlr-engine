# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::DocumentHelperBehavior do
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  describe '#document_presenter_class' do
    before :each do
      allow(helper).to receive(:formats).and_return([:json])
    end

    it 'returns JsonIndexPresenter for JSON requests' do
      expect(helper.document_presenter_class(document)).to eq CommonwealthVlrEngine::JsonIndexPresenter
    end
  end
end
