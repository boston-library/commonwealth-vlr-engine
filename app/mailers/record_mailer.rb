# frozen_string_literal: true

# overriding Blacklight RecordMailer to add :from address in email
# otherwise we get error: ArgumentError (An SMTP From address is required to send a message
class RecordMailer < ApplicationMailer
  def email_record(documents, details, url_gen_params)
    subject = I18n.t('blacklight.email.text.subject', count: documents.length,
                     title: (documents.first.to_semantic_values[:title] rescue 'N/A'))

    @documents      = documents
    @message        = details[:message]
    @url_gen_params = url_gen_params

    mail(to: details[:to],
         from: t('blacklight.email.record_mailer.name') + ' <' + t('blacklight.email.record_mailer.email') + '>',
         subject: subject)
  end
end
