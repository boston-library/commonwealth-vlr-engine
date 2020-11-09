# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class EnvironmentGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc "This generator makes the following changes to your application:
          1. Adds some settings for asset precompilation to config/initializers/assets.rb
          2. Adds some settings for security and mailers to config/application.rb"

    # add settings to application.rb
    def inject_application_settings
      return if IO.read('config/application.rb').include?('config.action_mailer.delivery_method')

      marker = 'class Application < Rails::Application'
      insert_into_file 'config/application.rb', after: marker do
        %q(

    # don't log passwords
    config.filter_parameters += [:password]

    # mailer settings
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = { host: 'awesomelibrary.org' }

    # Added these to handle some CORS issues seen in the javascript during an OCR search.
    # Ideally this should be handled by a rack/cors initializer.
    # See https://github.com/cyu/rack-cors for more info
    config.action_dispatch.default_headers.merge!(
      {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'POST, PUT, DELETE, GET, OPTIONS',
        'Access-Control-Max-Age' => "1728000",
        'Access-Control-Allow-Headers' =>'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      }
    )
)
      end
    end
  end
end
