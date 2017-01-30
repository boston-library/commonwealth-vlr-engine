require 'spec_helper'

describe CitationHelper do

  include Blacklight::SearchHelper

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { Blacklight.default_index.search({:q => "id:\"#{item_pid}\"", :rows => 1}).documents.first }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#citation_styles' do
    it 'should return an array of strings' do
      expect(helper.citation_styles[0]).to eq('mla')
    end
  end

  describe '#render_citations' do
    let(:citation_styles_array) { helper.citation_styles }
    let(:render_citations_output) { helper.render_citations([document], citation_styles_array) }
    it 'should return set of formatted citations' do
      expect(render_citations_output.scan(/Beauregard/).length).to eq(citation_styles_array.length)
    end
  end

  describe '#render_citation' do
    it 'should return a citation formatted in the style given as an argument' do
      expect(helper.render_citation(document, 'mla')).to include('Web.')
    end
  end

  describe '#render_mla_citation' do
    it 'should return a formatted citation' do
      expect(helper.render_mla_citation(document)).to include('Web.')
    end
  end

  describe '#render_apa_citation' do
    it 'should return a formatted citation' do
      expect(helper.render_apa_citation(document)).to include('(1859)')
    end
  end

  describe '#render_chicago_citation' do
    it 'should return a formatted citation' do
      expect(helper.render_chicago_citation(document)).to include(I18n.t('blacklight.application_name'))
    end
  end

  describe '#names_for_citation' do

    let(:multiname_document) {
      Blacklight.default_index.search({:q => "id:\"bpl-dev:df65v788h\"", :rows => 1}).documents.first
    }

    it 'should return a properly formatted list of names' do
      expect(helper.names_for_citation(multiname_document, 'apa')).to include('Zeno, N., & Zeno, A.')
      expect(helper.names_for_citation(multiname_document, 'mla')).to include('Zeno, Niccolò, and Antonio Zeno')
    end

  end

  describe '#publishing_data_for_citation' do
    it 'should return properly formatted publishing info' do
      expect(helper.publishing_data_for_citation(document)).to include('New York: Published by E & H. T. Anthony,')
    end
  end

  describe '#date_for_citation' do
    it 'should return a properly formatted date' do
      expect(helper.date_for_citation(document[:date_start_tsim].first, 'apa')).to include('(1859).')
      expect(helper.date_for_citation(document[:date_start_tsim].first, 'mla')).to include('1859.')
    end
  end

  describe '#title_for_citation' do
    it 'should return a properly formatted title' do
      expect(helper.title_for_citation(document, 'mla')).to include('<em>Beauregard</em>')
      expect(helper.title_for_citation(document, 'chicago')).to include('"Beauregard."')
    end
  end

  describe '#genre_for_citation' do
    it 'should return a properly formatted genre' do
      expect(helper.genre_for_citation(document[:genre_basic_ssim].first)).to match(/Photograph\z/)
    end
  end

  describe '#url_for_citation' do
    it 'should return the correct URL' do
      expect(helper.url_for_citation(document)).to include(document[:identifier_uri_ss])
    end
  end

end