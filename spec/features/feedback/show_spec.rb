# frozen_string_literal: true

require 'rails_helper'

describe 'feedback form', js: true do
  before(:each) do
    visit feedback_path
  end

  describe 'feedback help alerts' do
    let(:contact_help_text_id) { '#contact_help_text' }

    it 'does not display the feedback help text' do
      expect(page).to have_selector(contact_help_text_id, visible: false)
    end

    describe 'selecting type option with help text' do
      before(:each) do
        select I18n.t('blacklight.feedback.form.topic.options.repro.option'), from: 'message_type_select'
      end

      it 'displays the feedback help text' do
        expect(page).to have_selector(contact_help_text_id, visible: true)
      end

      describe 'selecting type option without help text' do
        before(:each) do
          select I18n.t('blacklight.feedback.form.topic.options.default.option'), from: 'message_type_select'
        end

        it 'does not display the feedback help text' do
          expect(page).to have_selector(contact_help_text_id, visible: false)
        end
      end
    end
  end
end
