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
        insert_into_file 'config/application.rb', :after => marker do
          %q{

    # don't log passwords
    config.filter_parameters += [:password, password_confirmation]
    # escape HTML entities in JSON
    config.active_support.escape_html_entities_in_json = true
    # mailer settings
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = { :host => 'awesomelibrary.org' }
}

        end

      end
    end

    # add settings to assets.rb
    def inject_asset_settings
      unless IO.read('config/initializers/assets.rb').match(/^[^#]*config.assets.precompile/)
        marker = '# Precompile additional assets.'
        insert_into_file 'config/initializers/assets.rb', :after => marker do
          %q{
Rails.application.config.assets.precompile += %w(wdl-viewer/fd-slider.min.css ie_fixes.css *.js)
}

        end

      end
    end

  end
end