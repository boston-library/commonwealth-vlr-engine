require 'rails/generators'

module CommonwealthVlrEngine
  class EnvironmentGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    desc """
  This generator makes the following changes to your application:
   1. Adds some settings for asset precompilation to config/initializers/assets.rb
   2. Adds some settings for security and mailers to config/application.rb
  Thank you for installing Commonwealth VLR.
         """

    # add settings to application.rb
    def inject_application_settings
      unless IO.read('config/application.rb').include?('config.action_mailer.delivery_method')
        marker = 'class Application < Rails::Application'
        insert_into_file 'config/application.rb', after: marker do
          %q{

    # don't log passwords
    config.filter_parameters += [:password]
    # mailer settings
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = { :host => 'awesomelibrary.org' }
    #Added these to handle some CORS issues seen in the javascript during an OCR search.
    #Ideally this should be handled by a rack/cors initializer.
    #See https://github.com/cyu/rack-cors for more info
    config.action_dispatch.default_headers.merge!(
      {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'POST, PUT, DELETE, GET, OPTIONS',
        'Access-Control-Max-Age' => "1728000",
       'Access-Control-Allow-Headers' =>'Origin, X-Requested-With, Content-Type, Accept, Authorization'
     })
}

        end

      end
    end

    # add settings to assets.rb
    def inject_asset_settings
      unless IO.read('config/initializers/assets.rb').match(/^[^#]*config.assets.precompile/)
        marker = '# Precompile additional assets.'
        insert_into_file 'config/initializers/assets.rb', after: marker do
          %q{
Rails.application.config.assets.precompile += %w(*.js)
}

        end

      end
    end

  end
end
