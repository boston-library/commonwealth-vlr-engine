# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthFlaggedSearchBuilder do
  let(:search_builder) { described_class.new(CatalogController.new) }

  describe 'processor chain' do
    it 'adds the right methods to the processor chain' do
      expect(search_builder.processor_chain).to include(:flagged_filter)
    end
  end
end
