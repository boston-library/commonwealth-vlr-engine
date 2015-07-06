module CommonwealthVlrEngine

  class Notifier < ActionMailer::Base

    def feedback(details)

      @message = details[:message]
      @topic = details[:topic]
      @email = details[:email]
      @name = details[:name]
      @recipient = route_email(details[:topic])

      mail(:to => @recipient,
           :from => t('blacklight.email.record_mailer.name') + ' <' + t('blacklight.email.record_mailer.email') + '>',
           :subject => t('blacklight.feedback.text.subject'))

    end

    # re-creating Blacklight RecordMailer#email_record because
    def email_record(documents, details, url_gen_params)

      subject = I18n.t('blacklight.email.text.subject', :count => documents.length, :title => (documents.first.to_semantic_values[:title] rescue 'N/A') )

      @documents      = documents
      @message        = details[:message]
      @url_gen_params = url_gen_params

      mail(:to => details[:to],  :subject => subject)
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

