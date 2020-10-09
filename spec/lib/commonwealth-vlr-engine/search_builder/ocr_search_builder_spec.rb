require 'rails_helper'

describe CommonwealthOcrSearchBuilder do
  let(:search_builder) { described_class.new(CatalogController.new) }

  describe 'processor chain' do
    it 'adds the right methods to the processor chain' do
      expect(search_builder.processor_chain).to include(:ocr_search_params)
    end
  end
end
