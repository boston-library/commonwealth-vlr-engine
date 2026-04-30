# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::MetadataHelperBehavior do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }

  before(:each) do
    without_partial_double_verification do
      allow(helper).to receive_messages(blacklight_config: blacklight_config)
    end
  end

  describe '#render_constituent' do
    let(:item_pid) { 'bpl-dev:00000003t' }

    it 'returns the formatted value' do
      expect(helper.render_constituent(document)).to include('free<br>Dudley')
    end
  end

  describe '#render_toc' do
    let(:item_pid) { 'bpl-dev:00000003t' }

    it 'returns the formatted value' do
      expect(helper.render_toc(document)).to include('Plain<br>Brookline')
    end
  end

  describe '#index_date_value' do
    it 'returns the date value for the catalog#index view' do
      expect(helper.index_date_value({ document: document })).to eq('[ca. 1859–1870]')
    end
  end

  describe '#index_creator_value' do
    it 'returns the creator values for the catalog#index view' do
      expect(helper.index_creator_value({ document: document })).to eq('Marsh, Amy')
    end
  end

  describe '#date_qualifier' do
    it 'returns date qualifier values' do
      expect(helper.date_qualifier('copyrightDate')).to eq('copyright')
    end
  end

  # describe '#render_hiergo_subject' do
  #   subject { helper.render_hiergo_subject(document[:subject_hiergeo_geojson_ssm].first, ' | ') }
  #
  #   it 'returns a set of links to geographic subjects' do
  #     expect(subject.scan(/href=\"\/search\?f%5Bsubject_geographic_sim/).length).to eq(3)
  #   end
  #
  #   it 'should join the links using the separator' do
  #     expect(subject.scan(/<span> \| <\/span>/).length).to eq(2)
  #   end
  #
  #   it 'adds the county label to the county value' do
  #     expect(subject).to include(' (county)')
  #   end
  # end

  describe 'title helpers' do
    describe '#render_title' do
      describe 'full title with subtitle' do
        let(:doc_with_subtitle) { SolrDocument.find('bpl-dev:00000003t') }

        it 'renders the title correctly' do
          expect(helper.render_title(doc_with_subtitle)).to include('Massachusetts : based')
        end
      end

      describe 'main title' do
        it 'renders the title correctly' do
          expect(helper.render_title({ 'title_info_primary_tsi' => 'Foo',
                                       title_info_partnum_tsi: 'vol.2' })).to eq('Foo. vol.2')
        end
      end
    end

    describe '#render_alt_title' do
      let(:doc_with_alt_title) do
        { 'title_info_alternative_tsim' => ['Modest'],
          'title_info_other_subtitle_tsim' => ['Expectations'] }
      end

      it 'renders the alt title' do
        expect(helper.render_alt_title(doc_with_alt_title, 0)).to eq 'Modest : Expectations'
      end
    end
  end

  describe '#render_mods_xml_record' do
    let(:mods_xml_doc) { helper.render_mods_xml_record(document) }

    it 'returns the XML document for the MODS record' do
      expect(mods_xml_doc.class).to eq(REXML::Document)
      expect(mods_xml_doc.to_s).to include('<mods:title>Beauregard</mods:title>')
    end
  end

  describe '#setup_names_roles' do
    let(:doc_with_names) { SolrDocument.find('bpl-dev:df65v788h') }
    let(:names_roles) { helper.setup_names_roles(doc_with_names) }
    let(:roles) { names_roles.keys }

    it 'returns a hash where the values are arrays' do
      expect(roles.length).to eq(2)
      expect(names_roles[roles.first]).to be_an(Array)
    end

    it 'has the correct values in the arrays' do
      expect(roles.first).to eq('Cartographer')
      expect(names_roles[roles.first].first).to include('Niccolo')
      expect(roles[1]).to eq('Creator')
      expect(names_roles[roles[1]].first).to include('Antonio')
    end
  end

  describe '#show_abstract' do
    let(:item_pid) { 'bpl-dev:abcd12345' }

    it 'returns the formatted value' do
      expect(helper.show_abstract(document)).to include('<br>')
    end
  end
end
