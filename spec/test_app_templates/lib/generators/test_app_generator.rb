require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base

  def remove_index
    remove_file "public/index.html"
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)

    Bundler.with_clean_env do
      run "bundle install"
    end

    generate 'blacklight:install'
  end

  def run_vlr_engine_install
    generate 'commonwealth_vlr_engine:install'
  end

  # TODO: configure various YAML files, run db migrations, set institutions = true, etc.

end