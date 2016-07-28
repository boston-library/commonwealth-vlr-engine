require 'spec_helper'

describe CommonwealthVlrEngine::RenderConstraintsOverride do

  class RenderConstraintsOverrideTestClass < CatalogController
    attr_accessor :params
  end

  before(:each) do
    @fake_controller = RenderConstraintsOverrideTestClass.new
    @fake_controller.extend(CommonwealthVlrEngine::RenderConstraintsOverride)
    @fake_controller.params = { mlt_id: 'bpl-dev:h702q6403' }
  end

  describe "testing for mlt parameters" do

    describe "has_mlt_parameters?" do

      it "should be true if mlt params are present" do
        expect(@fake_controller.has_mlt_parameters?).to be true
      end

    end

    describe "has_search_parameters?" do

      it "should be true if mlt params are present" do
        expect(@fake_controller.has_search_parameters?).to be true
      end

    end

  end

  describe "render_constraint_element" do

    # TODO: can't get the spec below to pass, getting error:
    # NoMethodError: super: no superclass method `render_constraint_element'

    it "should render AZ link constraints properly" #do
      #expect(@fake_controller.render_constraint_element(nil, "title_info_primary_ssort:B*")).to
        #have_content("Starts with")
    #end

  end

  describe "render mlt constraints" do

    before do
      @test_params = @fake_controller.params
    end

    describe "query_has_constraints?" do

      it "should be true if there are mlt params" do
        expect(@fake_controller.query_has_constraints?).to be true
      end

    end


    describe "render_mlt_query" do

      before :each do
        # have to create a request or call to 'url_for' returns an error
        @fake_controller.request = ActionDispatch::Request.new(params:{controller: 'catalog', action: 'index'})
        @fake_controller.request.path_parameters[:controller] = 'catalog'
      end

      # TODO: can't get these specs to pass, getting error:
      # NoMethodError: undefined method `render_constraint_element'

      it "should render the mlt id" #do
        #expect(@fake_controller.render_mlt_query(@test_params)).to have_content(@fake_controller.params[:mlt_id])
      #end

      it "should remove spatial params in the 'remove' link" #do
      #expect(@fake_controller.render_mlt_query(@test_params)).to_not have_content("spatial_search_type")
      #end

    end

  end



end