# frozen_string_literal: true

class FeedbackController < ApplicationController
  # http://expressica.com/simple_captcha/
  # include SimpleCaptcha::ControllerHelpers

  # show the feedback form
  def show
    @nav_li_active = 'about'
    @errors = []
    return unless request.post? && validate

    Notifier.feedback(params).deliver_now
    redirect_to feedback_complete_path
  end

  protected

  # validates the incoming params
  # returns either an empty array or an array with error messages
  def validate
    @errors << t('blacklight.feedback.valid_name') unless params[:name]&.match?(/\w+/)
    @errors << t('blacklight.feedback.valid_email') unless params[:email]&.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    @errors << t('blacklight.feedback.need_message') unless params[:message]&.match?(/\w+/)
    # @errors << 'Captcha did not match' unless simple_captcha_valid?
    @errors.empty?
  end
end
