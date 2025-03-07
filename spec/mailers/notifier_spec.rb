# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::Notifier do
  describe 'feedback' do
    let(:email_params) do
      { name: 'Testy McGee', email: 'testy@example.com', topic: 'image reproduction',
        message: 'Test message' }
    end
    let(:test_feedback_email) { Notifier.feedback(email_params) }

    it 'creates the email' do
      expect(test_feedback_email).not_to be_nil
    end

    it 'has the right user email in the text' do
      expect(test_feedback_email.body.encoded).to include(email_params[:email])
    end

    it 'has the right receiver email address' do
      expect(test_feedback_email.to[0]).to eq(CommonwealthVlrEngine.config.dig(:contact_emails, :image_requests))
    end
  end
end
