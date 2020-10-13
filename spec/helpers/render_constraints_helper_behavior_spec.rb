require 'rails_helper'

describe CommonwealthVlrEngine::RenderConstraintsHelperBehavior do
  let(:mlt_id) { 'bpl-dev:h702q6403' }
  let(:mock_controller) { CatalogController.new }
  let(:search_state) do
    mock_controller.search_state_class.new(mock_controller.params,
                                           mock_controller.blacklight_config,
                                           mock_controller)
  end

  before(:each) do
    mock_controller.params = { mlt_id: mlt_id }
  end

  describe 'has_? methods' do
    describe "#query_has_constraints?" do
      it "should be true if mlt params are present" do
        expect(helper.query_has_constraints?(search_state)).to be_truthy
      end
    end

    describe "#has_mlt_parameters?" do
      it "should be true if mlt params are present" do
        expect(helper.has_mlt_parameters?(search_state)).to be_truthy
      end
    end
  end

  describe 'rendering constraints' do
    before(:each) do
      mock_controller.params['spatial_search_type'] = 'point'
      mock_controller.params['date_start'] = '1970'
      mock_controller.params['date_end'] = '2000'
      allow(helper).to receive(:convert_to_search_state).and_return(search_state)
      allow(helper).to receive(:search_action_path) do |*args|
        search_catalog_path *args
      end
    end

    describe "#render_constraint_element" do
      it "renders AZ link constraints properly" do
        expect(helper.render_constraint_element(nil, "title_info_primary_ssort:B*")).to have_content("Starts with")
      end
    end

    describe '#render_constraints' do
      it 'renders mlt constraints' do
        expect(helper.render_constraints(mock_controller.params, search_state)).to have_content(mlt_id)
      end
    end

    describe '#date_range_constraints_to_s' do
      it 'returns the right string' do
        expect(helper.date_range_constraints_to_s(mock_controller.params)).to eq('1970-2000')
      end
    end

    describe "#render_advanced_date_query" do
      it "renders the date range" do
        expect(helper.render_advanced_date_query(search_state)).to have_content('1970-2000')
      end

      it "should remove spatial params in the 'remove' link" do
        expect(helper.render_advanced_date_query(search_state)).to_not have_content("spatial_search_type")
      end
    end

    describe "#render_mlt_query" do
      it "renders the mlt id" do
        expect(helper.render_mlt_query(search_state)).to have_content(mlt_id)
      end

      it "should remove spatial params in the 'remove' link" do
        expect(helper.render_mlt_query(search_state)).to_not have_content("spatial_search_type")
      end
    end
  end
end
