# frozen_string_literal: true

require 'rails_helper'

describe FeedbackController do
  render_views
  describe 'show' do
    describe 'GET' do
      it 'renders the contact form' do
        get :show
        expect(response).to be_successful
        expect(response.body).to have_selector("form[id='feedback_form']")
      end
    end

    describe 'POST' do
      describe 'failure' do
        it 'displays an error message for blank submission' do
          post :show
          expect(response.body).to have_selector("div[id='error_explanation']")
          expect(response).not_to redirect_to(feedback_complete_path)
        end

        it 'displays an error message for invalid submission' do
          post :show, params: { name: '%^*)(', email: 'thisnotvalid', topic: 'whatever', message: '%^*)(' }
          expect(response.body).to have_selector("div[id='error_explanation']")
          expect(response).not_to redirect_to(feedback_complete_path)
        end
      end

      describe 'success' do
        it 'redirects to the complete path' do
          post :show, params: { name: 'Testy McGee', email: 'test@test.edu', topic: 'whatever', message: 'Test message' }
          expect(response).to redirect_to(feedback_complete_path)
        end

        it 'creates the email' do
          post :show, params: { name: 'Testy McGee', email: 'test@test.edu', topic: 'whatever', message: 'Test message' }
          expect(ActionMailer::Base.deliveries.last.body.encoded).to include('Test message')
        end
      end
    end
  end

  describe 'item' do
    let(:ark_id) { 'bpl-dev:df65v790j' }

    describe 'GET' do
      it 'renders the item contact form' do
        get :item, params: { ark_id: ark_id }
        expect(response).to be_successful
        expect(response.body).to have_selector("form[id='item_feedback_form']")
      end
    end

    describe 'POST' do
      describe 'failure' do
        it 'displays an error message for blank submission' do
          post :item, params: { ark_id: ark_id }
          expect(response.body).to have_selector("div[id='error_explanation']")
          expect(response.body).to have_selector("form[id='item_feedback_form']")
        end

        it 'displays an error message for invalid submission' do
          post :item, params: { ark_id: ark_id, name: '%^*)(', email: 'thisnotvalid', topic: 'whatever', message: '%^*)(' }
          expect(response.body).to have_selector("div[id='error_explanation']")
          expect(response.body).to have_selector("form[id='item_feedback_form']")
        end
      end

      describe 'success' do
        it 'redirects to the complete path' do
          post :item, params: { ark_id: ark_id, name: 'Testy McGee', email: 'test@test.edu', topic: 'whatever', message: 'Test message' }
          expect(response).to redirect_to(solr_document_path(ark_id))
        end

        it 'creates the email' do
          post :item, params: { ark_id: ark_id, name: 'Testy McGee', email: 'test@test.edu', topic: 'whatever', message: 'Test message' }
          expect(ActionMailer::Base.deliveries.last.body.encoded).to include('Test message')
        end
      end
    end
  end
end
