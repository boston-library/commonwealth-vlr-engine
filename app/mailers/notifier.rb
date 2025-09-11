# frozen_string_literal: true

class Notifier < ActionMailer::Base
  include CommonwealthVlrEngine::Notifier
end
