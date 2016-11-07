require 'spec_helper'

describe CommonwealthVlrEngine::SearchHistoryConstraintsHelper do

  class SearchHistoryConstraintsHelperTestClass < CatalogController
    attr_accessor :params
    include CommonwealthVlrEngine::ApplicationHelper
  end

  before(:each) do
    @fake_controller = SearchHistoryConstraintsHelperTestClass.new
    @fake_controller.extend(CommonwealthVlrEngine::SearchHistoryConstraintsHelper)
  end

  describe 'render_search_to_s_mlt' do

    let (:mlt_test_params) { {mlt_id: 'bpl-dev:h702q6403'} }

    it 'should return render_search_to_s_element when mlt params are present' do
      expect(@fake_controller).to receive(:render_search_to_s_element)
      expect(@fake_controller).to receive(:render_filter_value)
      @fake_controller.render_search_to_s_mlt(mlt_test_params)
    end

  end

  describe 'render_search_to_s_advanced' do

    let (:date_range_params) { {date_start: '1970', date_end: '2000'} }

    it 'should return render_search_to_s_element when date range params are present' do
      expect(@fake_controller).to receive(:render_search_to_s_element)
      expect(@fake_controller).to receive(:render_filter_value)
      @fake_controller.render_search_to_s_advanced(date_range_params)
    end

  end

end