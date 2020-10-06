require 'rails_helper'

describe 'feedback form', js: true do

  before do
    visit feedback_path
  end

  describe 'feedback help alerts' do

    let(:contact_help_text_id) { '#contact_help_text' }

    it 'should not display the feedback help text' do
      expect(page).to have_selector("#{contact_help_text_id}.hidden", visible: false)
    end

    describe 'selecting type option with help text' do

      before do
        select I18n.t('blacklight.feedback.form.topic.options.repro.option'), :from => 'message_type_select'
      end

      it 'displays the feedback help text' do
        expect(page).not_to have_selector("#{contact_help_text_id}.hidden")
        expect(page).to have_selector("#{contact_help_text_id}", visible: true)
      end

      describe 'then selecting type option without help text' do

        before do
          select I18n.t('blacklight.feedback.form.topic.options.default.option'), :from => 'message_type_select'
        end

        it 'should not display the feedback help text' do
          expect(page).to have_selector("#{contact_help_text_id}.hidden", visible: false)
        end

      end

    end

  end

end



