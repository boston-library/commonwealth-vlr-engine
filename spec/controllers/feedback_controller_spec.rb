require 'spec_helper'

describe FeedbackController do

  render_views

  describe "GET show" do

    it "should render the contact form" do
      get :show
      expect(response).to be_successful
      expect(response.body).to have_selector("form[id='feedback_form']")
    end

  end

  describe "POST show" do

    describe "failure" do

      it "should display an error message for blank submission" do
        post :show
        expect(response.body).to have_selector("div[id='error_explanation']")
        expect(response).not_to redirect_to(feedback_complete_path)
      end

      it "should display an error message for invalid submission" do
        post :show, params: {:name => '%^*)(', :email => 'thisnotvalid', :topic => 'whatever', :message => '%^*)(' }
        expect(response.body).to have_selector("div[id='error_explanation']")
        expect(response).not_to redirect_to(feedback_complete_path)
      end

    end

    describe "success" do

      it "should redirect to the complete path" do
        post :show, params: {:name => 'Testy McGee', :email => 'test@test.edu', :topic => 'whatever', :message => 'Test message'}
        expect(response).to redirect_to(feedback_complete_path)
      end

      it "should create the email" do
        post :show, params: {:name => 'Testy McGee', :email => 'test@test.edu', :topic => 'whatever', :message => 'Test message'}
        expect(ActionMailer::Base.deliveries.last.body.encoded).to include('Test message')
      end

    end

  end

end
