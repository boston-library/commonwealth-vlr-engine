require 'rails_helper'

describe CommonwealthInstitutionsSearchBuilder do
  let(:search_builder) { described_class.new(CatalogController.new) }

  describe 'processor chain' do
    it 'adds the right methods to the processor chain' do
      expect(search_builder.processor_chain).to include(:institutions_filter)
    end
  end
end
