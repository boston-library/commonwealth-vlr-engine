# frozen_string_literal: true

class FeedbackController < ApplicationController
  # show the feedback form
  def show
    @nav_li_active = 'about'
    @errors = []
    return unless request.post? && validate

    Notifier.feedback(params).deliver_now
    redirect_to feedback_complete_path
  end

  # item-level feedback form, displayed as modal popup on catalog#show
  # based on Blacklight::ActionBuilder#build
  def item
    @document = SolrDocument.find(params[:ark_id])
    @errors = []

    if request.post? && validate
      Notifier.feedback(params).deliver_now
      flash[:success] = t('blacklight.feedback.complete.title')
      respond_to do |format|
        format.html do
          return render 'item_success' if request.xhr?

          redirect_to solr_document_path(params[:ark_id])
        end
      end
    else
      respond_to do |format|
        format.html do
          return render layout: false if request.xhr?
          # Otherwise draw the full page
        end
      end
    end
  end

  protected

  # validates the incoming params
  # returns either an empty array or an array with error messages
  def validate
    @errors << t('blacklight.feedback.valid_name') unless params[:name]&.match?(/\w+/)
    @errors << t('blacklight.feedback.valid_email') unless params[:email]&.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    @errors << t('blacklight.feedback.need_message') unless params[:message]&.match?(/\w+/)
    @errors << t('blacklight.feedback.recaptcha') unless verify_recaptcha
    @errors.empty?
  end
end
