# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::BlacklightHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:search_service) { Blacklight::SearchService.new(config: blacklight_config) }
  let(:document) { SolrDocument.find('bpl-dev:h702q6403') }

  before :each do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#document_presenter_class' do
    before :each do
      allow(helper).to receive(:formats).and_return([:json])
    end

    it 'returns JsonIndexPresenter for JSON requests' do
      expect(helper.document_presenter_class(document)).to eq CommonwealthVlrEngine::JsonIndexPresenter
    end
  end

  describe 'document_heading methods' do
    let(:document) { SolrDocument.find('bpl-dev:3j334603p') }

    describe '#document_heading' do
      let(:heading) { helper.document_heading(document) }

      it 'returns the properly formatted heading' do
        expect(heading).to include document['title_info_primary_tsi']
        expect(heading).to include document['title_info_primary_subtitle_tsi']
        expect(heading).to include document['title_info_partnum_tsi']
      end
    end

    describe '#render_document_heading' do
      let(:heading) { helper.render_document_heading(document) }

      it 'returns the properly formatted heading' do
        expect(heading).to include document['title_info_primary_subtitle_tsi']
      end
    end
  end

  describe '#extra_body_classes' do
    let(:classes) { helper.extra_body_classes }
    before :each do
      allow(helper).to receive(:controller_name).and_return('pages')
      allow(helper).to receive(:action_name).and_return('home')
    end

    it 'returns the expected class values' do
      expect(classes).to include 'blacklight-home'
      expect(classes).to include 'blacklight-pages'
    end
  end

  describe '#render_link_rel_alternates' do
    it 'returns nil' do
      expect(helper.render_link_rel_alternates(document)).to be_nil
    end
  end
end
