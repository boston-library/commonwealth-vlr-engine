require 'spec_helper'

describe CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior do

  let(:blacklight_params) { Hash.new }
  let(:solr_parameters) { Blacklight::Solr::Request.new }

  let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }
  let(:user_params) { Hash.new }
  let(:context) { CatalogController.new }

  before { allow(context).to receive(:blacklight_config).and_return(blacklight_config) }

  let(:search_builder_class) do
    Class.new(Blacklight::SearchBuilder) do
      include Blacklight::Solr::SearchBuilderBehavior
      include CommonwealthVlrEngine::CommonwealthSearchBuilderBehavior
    end
  end

  let(:search_builder) { search_builder_class.new(context) }

  describe 'exclude_unwanted_models' do

    it 'should add parameters to exclude unwanted models' do
      expect(search_builder.exclude_unwanted_models(solr_parameters).to_s).to include('afmodel:Bplmodels_File')
    end

  end

  describe 'exclude_unpublished_items' do

    let(:excluded_unpublished) { search_builder.exclude_unpublished_items(solr_parameters).to_s }

    it 'should add parameters to exclude non-published items' do
      expect(excluded_unpublished).to include('draft')
      expect(excluded_unpublished).to include('needs_review')
      expect(excluded_unpublished).to include('derivatives')
    end

  end

  describe 'exclude_institutions' do

    it 'should add parameters to exclude institutions' do
      expect(search_builder.exclude_institutions(solr_parameters).to_s).to include('-active_fedora_model_suffix_ssi:\"Institution\"')
    end

  end

  describe 'flagged_filter' do

    it 'should add parameters to exclude flagged items' do
      expect(search_builder.flagged_filter(solr_parameters).to_s).to include("-#{blacklight_config.flagged_field}:[* TO *]")
    end

  end

  describe 'institutions_filter' do

    it 'should add parameters to require institutions' do
      expect(search_builder.institutions_filter(solr_parameters).to_s).to include('+active_fedora_model_suffix_ssi:\"Institution\"')
    end

  end

  describe 'institutions_limit' do

    it 'should add parameters to limit to a single institution' do
      expect(search_builder.institution_limit(solr_parameters).to_s).to include('+institution_pid_ssi:\"' + CommonwealthVlrEngine.config[:institution][:pid])
    end

  end

  describe 'mlt_params' do

    let(:builder_with_params) { search_builder.with({mlt_id: 'bpl-dev:12345678'}) }

    before do
      builder_with_params.mlt_params(solr_parameters)
    end

    it 'should set the id param to the mlt_id value' do
      expect(solr_parameters['id']).to eq('bpl-dev:12345678')
    end

    it 'should set the mlt query params' do
      expect(solr_parameters['qt']).to eq('mlt')
      expect(solr_parameters['mlt.fl']).to be_truthy
      expect(solr_parameters['mlt.qf']).to be_truthy
    end

  end

  describe 'collections_filter' do

    it 'should add parameters to require institutions' do
      expect(search_builder.collections_filter(solr_parameters).to_s).to include('+active_fedora_model_suffix_ssi:\"Collection\"')
    end

  end

  describe 'exclude_volumes' do

    it 'should add parameters to exclude volume objects' do
      expect(search_builder.exclude_volumes(solr_parameters).to_s).to include('-active_fedora_model_suffix_ssi:\"Volume\"')
    end

  end

  describe 'ocr_search_params' do

    before do
      search_builder.ocr_search_params(solr_parameters)
    end

    it 'should add parameters for field highlighting' do
      expect(solr_parameters.to_s).to include('"hl"=>true')
      expect(solr_parameters.to_s).to include('hl.fragsize')
      expect(solr_parameters.to_s).to include("\"hl.fl\"=>\"#{blacklight_config.ocr_search_field}\"")
    end

  end


end