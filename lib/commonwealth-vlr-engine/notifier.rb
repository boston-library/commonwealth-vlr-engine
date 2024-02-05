# frozen_string_literal: true

module CommonwealthVlrEngine
  module Notifier
    extend ActiveSupport::Concern

    def feedback(details)
      @message = details[:message]
      @topic = details[:topic]
      @email = details[:email]
      @name = details[:name]
      @recipient = route_email(details[:topic])

      mail(to: @recipient,
           from: t('blacklight.email.record_mailer.name') + ' <' + t('blacklight.email.record_mailer.email') + '>',
           subject: t('blacklight.feedback.text.subject', identifier: Time.zone.now.strftime('%s')))
    end

    private

    def route_email(topic)
      if topic == t('blacklight.feedback.form.topic.options.repro.option') ||
         topic == t('blacklight.feedback.item.topic.options.repro.option')
        CONTACT_EMAILS['image_requests']
      elsif topic == t('blacklight.feedback.form.topic.options.research.option')
        CONTACT_EMAILS['research_question']
      else
        CONTACT_EMAILS['site_admin']
      end
    end
  end
end
