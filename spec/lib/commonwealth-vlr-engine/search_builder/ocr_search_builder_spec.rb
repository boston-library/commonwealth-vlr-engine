require 'spec_helper'

describe CommonwealthOcrSearchBuilder do

  class CommonwealthOcrSearchBuilderTestClass < CommonwealthOcrSearchBuilder
  end

  before { @obj = CommonwealthOcrSearchBuilderTestClass.new(CatalogController.new) }

  describe 'processor chain' do

    it 'should add the right methods to the processor chain' do
      expect(@obj.processor_chain).to include(:ocr_search_params)
    end

  end


end