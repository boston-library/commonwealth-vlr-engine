require 'spec_helper'

describe RangeLimitHelper do

  let(:range_field_name) { 'date_facet_yearly_ssim' }
  let(:params) { {'f'=>{'institution_name_ssim'=>['Boston Public Library']},
                  'id'=>'bpl-dev:abcd12345',
                  'range_end'=>'1922s',
                  'range_field'=> range_field_name,
                  'range_start'=>'1851s'} }

  describe '#add_range_missing' do

    it 'create a link to catalog#show' do
      expect(helper.add_range_missing(range_field_name,params)).to include(search_catalog_path)
    end

  end

end