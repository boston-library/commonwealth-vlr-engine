# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OcrSearchHelper do
  describe '#ocr_q_params' do
    let(:current_search_session) { double(query_params: { 'q' => 'foo' }) }

    it 'returns the query params if they exist' do
      expect(helper.send(:ocr_q_params, current_search_session)).to eq('foo')
    end
  end
end
