# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CitationHelper do
  describe '#citation_styles' do
    it 'returns an array of strings' do
      expect(helper.citation_styles).to include('mla')
    end
  end
end
