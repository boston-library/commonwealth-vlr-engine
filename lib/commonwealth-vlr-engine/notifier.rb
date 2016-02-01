module CommonwealthVlrEngine
  module Notifier
    extend ActiveSupport::Concern

    def feedback(details)

      @message = details[:message]
      @topic = details[:topic]
      @email = details[:email]
      @name = details[:name]
      @recipient = route_email(details[:topic])

      mail(:to => @recipient,
           :from => t('blacklight.email.record_mailer.name') + ' <' + t('blacklight.email.record_mailer.email') + '>',
           :subject => t('blacklight.feedback.text.subject', identifier: Time.now.strftime('%s')))

    end

    private

    def route_email(topic)
      if topic == t('blacklight.feedback.form.topic.options.repro')
        recipient_email = CONTACT_EMAILS['image_requests']
      else
        recipient_email = CONTACT_EMAILS['site_admin']
      end
      recipient_email
    end



  end
end