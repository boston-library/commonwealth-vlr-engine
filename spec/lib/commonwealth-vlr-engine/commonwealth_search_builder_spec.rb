require 'spec_helper'

describe CommonwealthVlrEngine::CommonwealthSearchBuilder do

  class CommonwealthSearchBuilderTestClass
    cattr_accessor :blacklight_config, :blacklight_params

    include Blacklight::SearchHelper
    include CommonwealthVlrEngine::CommonwealthSearchBuilder

    def initialize blacklight_config, blacklight_params
      self.blacklight_config = blacklight_config
      self.blacklight_params = blacklight_params
    end

  end

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:blacklight_params) { Hash.new }
  let(:solr_parameters) { Blacklight::Solr::Request.new }

  before { @obj = CommonwealthSearchBuilderTestClass.new blacklight_config, blacklight_params }

  describe 'exclude_unwanted_models' do

    it 'should add parameters to exclude unwanted models' do
      expect(@obj.exclude_unwanted_models(solr_parameters).to_s).to include('afmodel:Bplmodels_File')
    end

    it 'should add parameters to exclude non-published items' do
      expect(@obj.exclude_unwanted_models(solr_parameters).to_s).to include('draft')
      expect(@obj.exclude_unwanted_models(solr_parameters).to_s).to include('needs_review')
    end

  end

  describe 'exclude_institutions' do

    it 'should add parameters to exclude institutions' do
      expect(@obj.exclude_institutions(solr_parameters).to_s).to include('-active_fedora_model_suffix_ssi:\"Institution\"')
    end

  end

  describe 'flagged_filter' do

    it 'should add parameters to exclude flagged items' do
      expect(@obj.flagged_filter(solr_parameters).to_s).to include("-#{blacklight_config.flagged_field}:[* TO *]")
    end

  end

  describe 'institutions_filter' do

    it 'should add parameters to require institutions' do
      expect(@obj.institutions_filter(solr_parameters).to_s).to include('+active_fedora_model_suffix_ssi:\"Institution\"')
    end

  end

  describe 'set_solr_id_for_mlt' do

    before {blacklight_params[:mlt_id] = 'bpl-dev:12345678'}

    it 'should set the id param to the mlt_id value' do
      expect(@obj.set_solr_id_for_mlt(solr_parameters)).to eq('bpl-dev:12345678')
    end

  end

  describe 'collections_filter' do

    it 'should add parameters to require institutions' do
      expect(@obj.collections_filter(solr_parameters).to_s).to include('+active_fedora_model_suffix_ssi:\"Collection\"')
    end

  end


end