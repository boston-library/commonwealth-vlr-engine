# -*- encoding : utf-8 -*-

require 'rails_helper'

describe InstitutionsHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:institution) { Blacklight.default_index.search({:q => "id:\"bpl-dev:abcd12345\"", :rows => 1}).documents.first }

  before :each do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#link_to_all_inst_items' do
    before { @institution_title = 'Foo Institution'}
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
    before { (@response, @document_list) = search_results({}) }

    describe 'with default document_index_view_type' do
      before { allow(helper).to receive_messages(document_index_view_type: :list) }
      subject { helper.render_institutions_index }
      it { should have_selector '#documents.documents-list' }
    end

    describe 'with "maps" document_index_view_type' do
      before do
        allow(helper).to receive_messages(blacklight_configuration_context: Blacklight::Configuration::Context.new(CatalogController.new))
        allow(helper).to receive_messages(document_index_view_type: :maps)
      end

      subject { helper.render_institutions_index }
      it { should have_selector 'div#institutions-index-map' }
    end

    # remove the instance variables so they don't mess up other specs
    after do
      remove_instance_variable(:@response)
      remove_instance_variable(:@document_list)
    end
  end

  describe '#should_render_inst_az?' do
    it 'returns false' do
     expect(helper.should_render_inst_az?).to be_falsey
    end
  end
end
