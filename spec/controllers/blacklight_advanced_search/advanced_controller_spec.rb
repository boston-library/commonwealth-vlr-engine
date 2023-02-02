# frozen_string_literal: true

require 'rails_helper'

describe AdvancedController do
  let(:mock_controller) { described_class.new }

  describe 'ft_field_display' do
    it 'updates the blacklight search_field config' do
      mock_controller.send(:ft_field_display)
      expect(mock_controller.blacklight_config.search_fields[mock_controller.blacklight_config.full_text_index].if).to eq(true)
    end
  end
end
