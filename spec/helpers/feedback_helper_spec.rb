# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackHelper do
  describe '#feedback_type_options' do
    it 'returns an array of feedback topics' do
      expect(helper.feedback_type_options).to be_a_kind_of Array
      expect(helper.feedback_type_options).to include(I18n.t('blacklight.feedback.form.topic.options').values.first[:option])
    end
  end
end
