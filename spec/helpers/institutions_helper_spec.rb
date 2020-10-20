# frozen_string_literal: true

require 'rails_helper'

describe InstitutionsHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:search_service) { Blacklight::SearchService.new(config: blacklight_config) }
  let(:institution) { SolrDocument.find('bpl-dev:abcd12345') }

  before :each do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#link_to_all_inst_items' do
    before(:each) { assign(:institution_title, 'Foo Institution') }

    it 'creates a search link with the correct institution params' do
      expect(helper.link_to_all_inst_items('foo')).to include("#{blacklight_config.institution_field}%5D%5B%5D=Foo+Institution")
    end
  end

  describe '#render_institution_desc' do
    let(:render_institution_desc_output) { helper.render_institution_desc(institution[:abstract_tsim]) }

    it 'creates the correct HTML content' do
      expect(render_institution_desc_output).to include('institution_desc_static')
      expect(render_institution_desc_output).to include('institution_desc_collapse')
      expect(render_institution_desc_output).to include('institution_desc_expand')
    end
  end

  describe 'render_institutions_index' do
    before(:each) do
      blacklight_config.search_builder_class = CommonwealthInstitutionsSearchBuilder
      (@response, @document_list) = search_service.search_results
    end

    # remove the instance variables so they don't mess up other specs
    after(:each) do
      remove_instance_variable(:@document_list)
      remove_instance_variable(:@response)
    end

    describe 'with default document_index_view_type' do
      before(:each) do
        allow(helper).to receive_messages(document_index_view_type: :list)
      end

      it 'calls render_document_index_with_view' do
        expect(helper).to receive(:render_document_index_with_view)
        helper.render_institutions_index(@document_list, {})
      end
    end

    describe 'with "maps" document_index_view_type' do
      subject { helper.render_institutions_index }

      let(:institutions_controller) { InstitutionsController.new }
      before(:each) do
        institutions_controller.params = {}
        institutions_controller.request = ActionDispatch::TestRequest.create
        allow(helper).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(CatalogController.new))
        allow(helper).to receive_messages(document_index_view_type: :maps)
        allow(helper).to receive_messages(controller: institutions_controller)
      end

      it { should have_selector 'div#institutions-index-map' }
    end
  end

  describe '#should_render_inst_az?' do
    it 'returns false' do
      expect(helper.should_render_inst_az?).to be_falsey
    end
  end
end
