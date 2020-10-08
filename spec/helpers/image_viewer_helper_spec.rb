require 'rails_helper'

describe ImageViewerHelper do
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }

  describe '#book_id' do
    it 'returns the correct document id' do
      expect(helper.book_id({is_volume_of_ssim: ['info:fedora/bpl-dev:abcd1234']})).to eq('bpl-dev:abcd1234')
      expect(helper.book_id(document)).to eq(item_pid)
    end
  end
end
