# frozen_string_literal: true

require 'rails/generators'

module CommonwealthVlrEngine
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    argument :search_builder_name, type: :string, default: 'search_builder'
    argument :document_name, type: :string, default: 'solr_document'
    argument :controller_name, type: :string, default: 'catalog'

    class_option :bpluser, type: :boolean, default: false, desc: 'Add user functionality using Devise and Bpluser'
    class_option :force, type: :boolean, default: false, desc: 'Force overwrite when copying files (for CI)'

    desc 'InstallGenerator Commonwealth VLR Engine'

    def verify_blacklight_installed
      return if IO.read('app/controllers/application_controller.rb').include?('include Blacklight::Controller')

      say_status('info', 'BLACKLIGHT NOT INSTALLED; GENERATING BLACKLIGHT', :blue)
      generate "blacklight:install#{ ' --devise' if options[:bpluser]}"
    end

    def bpluser_install
      return unless options[:bpluser]

      gem 'bpluser', github: 'boston-library/bpluser'

      Bundler.with_unbundled_env do
        run 'bundle install'
      end

      generate 'bpluser:install'
    end

    # def insert_to_assets
    #   generate 'commonwealth_vlr_engine:localassets'
    # end

    def copy_yml_files
      generate "commonwealth_vlr_engine:yml#{ ' --force' if options[:force]}"
    end

    def insert_to_controllers
      generate 'commonwealth_vlr_engine:controller', controller_name
    end

    def insert_to_models
      generate 'commonwealth_vlr_engine:model', search_builder_name, document_name
    end

    def add_vlr_initializers
      template 'config/initializers/a_load_commonwealth_vlr_configs.rb'
      template 'config/initializers/recaptcha.rb'
    end

    def insert_to_routes
      generate 'commonwealth_vlr_engine:routes'
    end

    # def insert_to_environments
    #   generate 'commonwealth_vlr_engine:environment'
    # end

    def mailer_sender
      return unless options[:bpluser]

      gsub_file('config/initializers/devise.rb', /^[\s#]*config.mailer_sender[^\n]*/,
                "  config.mailer_sender = CONTACT_EMAILS['site_admin']")
    end

    def bundle_install
      Bundler.with_unbundled_env do
        run 'bundle install'
      end
    end
  end
end
