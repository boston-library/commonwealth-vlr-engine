require 'spec_helper'

describe CommonwealthVlrEngine::ControllerOverride do

  class ControllerOverrideTestClass < CatalogController
    #include CommonwealthVlrEngine::ControllerOverride
  end

  before { @obj = ControllerOverrideTestClass.new }

  describe 'search_params_logic' do

    # TODO: fix the spec below, which is getting messed up by OcrSearchController.
    # On its own, this spec passes, but when run in CI/test-all context, it fails
    # because OcrSearchController removes :exclude_unwanted_models from its search_params_logic
    # but for some reason that removal carries over to other specs
    it 'should have exclude_unwanted_models included' #do
      #expect(@obj.search_params_logic).to include(:exclude_unwanted_models)
    #end

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