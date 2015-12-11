require 'spec_helper'

describe CommonwealthVlrEngine::ControllerOverride do

  class ControllerOverrideTestClass < CatalogController
    #include CommonwealthVlrEngine::ControllerOverride
  end

  before { @obj = ControllerOverrideTestClass.new }

  describe 'search_params_logic' do

    it 'should have exclude_unwanted_models included' do
      expect(@obj.search_params_logic).to include(:exclude_unwanted_models)
    end

    it 'should have exclude_unpublished_items included' do
      expect(@obj.search_params_logic).to include(:exclude_unpublished_items)
    end

  end

  describe 'search_builder_class' do

    it 'should have CommonwealthSearchBuilder included' do
      expect(@obj.blacklight_config.search_builder_class).to include(CommonwealthVlrEngine::CommonwealthSearchBuilder)
    end

  end

  describe 'add_institution_fields' do

    # this spec needs more work. not sure how to set appropriate institution stuff so it will pass
    # subject { @obj.send(:add_institution_fields) } ## not sure if I should use this??
    it 'should add institution facets to the blacklight_config' #do
    #  expect(@obj.blacklight_config.facet_fields).to include('physical_location_ssim')
    #end

  end

end