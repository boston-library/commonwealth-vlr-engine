require 'spec_helper'

describe CommonwealthVlrEngine::SearchHistoryConstraintsHelper do

  class SearchHistoryConstraintsHelperTestClass < CatalogController
    attr_accessor :params
  end

  before(:each) do
    @fake_controller = SearchHistoryConstraintsHelperTestClass.new
    @fake_controller.extend(CommonwealthVlrEngine::SearchHistoryConstraintsHelper)
    @test_params = { mlt_id: 'bpl-dev:h702q6403' }
  end

  describe 'render_search_to_s_mlt' do

    it 'should return render_search_to_s_element when mlt params are present' do
      expect(@fake_controller).to receive(:render_search_to_s_element)
      expect(@fake_controller).to receive(:render_filter_value)
      @fake_controller.render_search_to_s_mlt(@test_params)
    end

  end

end