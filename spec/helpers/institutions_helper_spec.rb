# -*- encoding : utf-8 -*-

require 'spec_helper'

describe InstitutionsHelper do

  include Blacklight::SearchHelper

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:search_params_logic) { CatalogController.search_params_logic += [:institutions_filter] }

  before :each do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#link_to_all_inst_items' do
    before { @institution_title = 'Foo Institution'}
    it 'should create a search link with the correct institution params' do
      expect(helper.link_to_all_inst_items('foo')).to include("#{blacklight_config.institution_field}%5D%5B%5D=Foo+Institution")
    end
  end

  describe 'render_institutions_index' do

    before { (@response, @document_list) = search_results({}, search_params_logic) }

    describe 'with default document_index_view_type' do
      before { allow(helper).to receive_messages(document_index_view_type: :list) }
      subject { helper.render_institutions_index }
      it { should have_selector '#documents.documents-list' }
    end

    describe 'with "maps" document_index_view_type' do
      before { allow(helper).to receive_messages(document_index_view_type: :maps) }
      subject { helper.render_institutions_index }
      it { should have_selector 'div#institutions-index-map' }
    end

    # remove the instance variables so they don't mess up other specs
    after {
      remove_instance_variable(:@response)
      remove_instance_variable(:@document_list)
    }

  end

end
