require 'rails_helper'

describe CommonwealthFlaggedSearchBuilder do

  class CommonwealthFlaggedSearchBuilderTestClass < CommonwealthFlaggedSearchBuilder
  end

  before { @obj = CommonwealthFlaggedSearchBuilderTestClass.new(CatalogController.new) }

  describe 'processor chain' do

    it 'adds the right methods to the processor chain' do
      expect(@obj.processor_chain).to include(:flagged_filter)
    end

  end


end