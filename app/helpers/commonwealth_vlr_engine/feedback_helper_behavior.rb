module CommonwealthVlrEngine
  module FeedbackHelperBehavior
    # returns an array of values for the message type select dropdown
    def feedback_type_options
      options_for_type_dropdown = []
      t('blacklight.feedback.form.topic.options').each_value do |option|
        options_for_type_dropdown << option[:option]
      end
      options_for_type_dropdown
    end

  end
end