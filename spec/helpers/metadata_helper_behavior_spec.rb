# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::MetadataHelperBehavior, :vcr do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }

  before(:each) do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#normalize_date' do
    it 'returns normalized date values' do
      expect(helper.normalize_date('2015-07-05')).to eq('July 5, 2015')
      expect(helper.normalize_date('2015-07')).to eq('July 2015')
    end
  end

  describe '#date_qualifier' do
    it 'returns date qualifier values' do
      expect(helper.date_qualifier('copyrightDate')).to eq('copyright')
    end
  end

  describe '#render_hiergo_subject' do
    subject { helper.render_hiergo_subject(document[:subject_hiergeo_geojson_ssm].first, ' | ') }

    it 'returns a set of links to geographic subjects' do
      expect(subject.scan(/href=\"\/search\?f%5Bsubject_geographic_sim/).length).to eq(3)
    end

    it 'should join the links using the separator' do
      expect(subject.scan(/<span> \| <\/span>/).length).to eq(2)
    end

    it 'adds the county label to the county value' do
      expect(subject).to include(' (county)')
    end
  end

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
          expect(helper.render_title({ title_info_primary_tsi: 'Foo', title_info_partnum_tsi: 'vol.2' },
                                     false)).to eq('Foo. vol.2')
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

  # render_mods_dates and #render_mods_date are deprecated in DC3
  #
  # describe '#render_mods_dates' do
  #   it 'returns an array of date values' do
  #     expect(helper.render_mods_dates(document).first).not_to be_nil
  #   end
  # end
  #
  # describe '#render_mods_date' do
  #   describe 'date with start, end, and qualifier' do
  #     it 'returns the correct date value' do
  #       expect(helper.render_mods_date('1984', '1985', 'approximate')).to eq('[ca. 1984–1985]')
  #     end
  #   end
  #
  #   describe 'copyright date' do
  #     it 'returns the correct date value' do
  #       expect(helper.render_mods_date('1984', nil, nil, 'copyrightDate')).to eq('(c) 1984')
  #     end
  #   end
  # end

  # TODO: re-enable once Curator supports MODS serialization endpoint
  # describe '#render_mods_xml_record' do
  #   let(:mods_xml_doc) { helper.render_mods_xml_record(item_pid) }
  #
  #   it 'returns the XML document for the MODS record' do
  #     expect(mods_xml_doc.class).to eq(REXML::Document)
  #     expect(mods_xml_doc.to_s).to include('<mods:title>Beauregard</mods:title>')
  #   end
  # end

  describe '#setup_names_roles' do
    let(:doc_with_names) { SolrDocument.find('bpl-dev:df65v788h') }
    let(:names_roles) { helper.setup_names_roles(doc_with_names) }
    let(:names) { names_roles[0] }
    let(:roles) { names_roles[1] }

    it 'returns two arrays of values' do
      expect(names.length).to eq(2)
      expect(roles.first).not_to be_nil
    end

    it 'has the correct values in the arrays' do
      expect(names[0]).to include('Niccolo')
      expect(roles[0]).to eq('Cartographer')
      expect(names[1]).to include('Antonio')
      expect(roles[1]).to eq('Creator')
    end
  end
end
