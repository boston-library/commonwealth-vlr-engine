require 'rails_helper'

describe CommonwealthVlrEngine::Notifier do

  describe "feedback" do

    before(:each) do
      @test_params = {
          :name => "Testy McGee",
          :email => "testy@example.com",
          :topic => "image reproduction",
          :message => "Test message"
      }
      @test_feedback_email = Notifier.feedback(@test_params)
    end

    it "creates the email" do
      expect(@test_feedback_email).not_to be_nil
    end

    it "has the right user email in the text" do
      expect(@test_feedback_email.body.encoded).to include(@test_params[:email])
    end

    it "has the right receiver email address" do
      expect(@test_feedback_email.to[0]).to eq(CONTACT_EMAILS['image_requests'])
    end

  end

end
