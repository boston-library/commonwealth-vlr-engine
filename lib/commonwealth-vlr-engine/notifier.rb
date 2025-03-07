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
      @document = SolrDocument.find(details[:ark_id]) if details[:ark_id].present?

      mail(to: @recipient,
           from: t('blacklight.email.record_mailer.name') + ' <' + t('blacklight.email.record_mailer.email') + '>',
           subject: t('blacklight.feedback.text.subject', identifier: Time.zone.now.strftime('%s')))
    end

    private

    def route_email(topic)
      if topic == t('blacklight.feedback.form.topic.options.repro.option') ||
         topic == t('blacklight.feedback.item.topic.options.repro.option')
        CommonwealthVlrEngine.config.dig(:contact_emails, :image_requests)
      elsif topic == t('blacklight.feedback.form.topic.options.research.option') ||
            topic == t('blacklight.feedback.item.topic.options.research.option')
        CommonwealthVlrEngine.config.dig(:contact_emails, :research_question)
      else
        CommonwealthVlrEngine.config.dig(:contact_emails, :site_admin)
      end
    end
  end
end
