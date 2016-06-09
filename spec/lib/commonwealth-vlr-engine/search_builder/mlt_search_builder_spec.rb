require 'spec_helper'

describe CommonwealthMltSearchBuilder do

  class CommonwealthMltSearchBuilderTestClass < CommonwealthMltSearchBuilder
  end

  before { @obj = CommonwealthMltSearchBuilderTestClass.new(CatalogController.new) }

  describe 'processor chain' do

    it 'should add the right methods to the processor chain' do
      expect(@obj.processor_chain).to include(:set_solr_id_for_mlt)
    end

  end


end