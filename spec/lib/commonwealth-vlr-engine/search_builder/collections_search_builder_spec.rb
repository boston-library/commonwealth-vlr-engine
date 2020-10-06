require 'rails_helper'

describe CommonwealthCollectionsSearchBuilder do

  class CommonwealthCollectionsSearchBuilderTestClass < CommonwealthCollectionsSearchBuilder
  end

  before { @obj = CommonwealthCollectionsSearchBuilderTestClass.new(CatalogController.new) }

  describe 'processor chain' do

    it 'adds the right methods to the processor chain' do
      expect(@obj.processor_chain).to include(:collections_filter)
    end

  end


end