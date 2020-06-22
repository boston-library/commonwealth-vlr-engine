require 'rails/generators'

module CommonwealthVlrEngine
  class DeviseGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "DeviseGenerator Commonwealth VLR Engine"

    argument :devise_initializer, type: :string, default: "config/initializers/devise.rb"

    def mailer_sender
      gsub_file(devise_initializer, /^[\s#]*config.mailer_sender[^\n]*/,
                "  config.mailer_sender = CONTACT_EMAILS['site_admin']")
    end

    def keys
      gsub_file(devise_initializer, /^[\s#]*config.authentication_keys[^\n]*/,
                '  config.authentication_keys = [ :uid ]')
      gsub_file(devise_initializer, /^[\s#]*config.case_insensitive_keys[^\n]*/,
                '  config.case_insensitive_keys = [ :uid ]')
      gsub_file(devise_initializer, /^[\s#]*config.strip_whitespace_keys[^\n]*/,
                '  config.strip_whitespace_keys = [ :uid ]')
    end

    def sign_out
      gsub_file(devise_initializer, /^[\s#]*config.sign_out_via[^\n]*/,
                '  config.sign_out_via = :get')
    end

    def omniauth
      return if IO.read(devise_initializer).include?('OMNIAUTH_POLARIS_GLOBAL')

      marker = '# ==> Warden configuration'
      insert_into_file devise_initializer, before: marker do
        "OMNIAUTH_POLARIS_GLOBAL = YAML.load_file(Rails.root.join('config', 'omniauth-polaris.yml'))[Rails.env]" \
        "\n  config.omniauth :polaris, title: OMNIAUTH_POLARIS_GLOBAL['title']," \
        "\n                  http_uri: OMNIAUTH_POLARIS_GLOBAL['http_uri']," \
        "\n                  access_key: OMNIAUTH_POLARIS_GLOBAL['access_key']," \
        "\n                  access_id: OMNIAUTH_POLARIS_GLOBAL['access_id']," \
        "\n                  method: OMNIAUTH_POLARIS_GLOBAL['method']\n" \
        "\n  OMNIAUTH_FACEBOOK_GLOBAL = YAML.load_file(Rails.root.join('config', 'omniauth-facebook.yml'))[Rails.env]" \
        "\n  config.omniauth :facebook, OMNIAUTH_FACEBOOK_GLOBAL['facebook_key']," \
        "\n                  OMNIAUTH_FACEBOOK_GLOBAL['facebook_secret']," \
        "\n                  scope: OMNIAUTH_FACEBOOK_GLOBAL['facebook_scope']\n\n  "
      end
    end
  end
end
