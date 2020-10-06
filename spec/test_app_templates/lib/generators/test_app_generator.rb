require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base

  def remove_index
    remove_file "public/index.html"
  end

  def run_vlr_engine_install
    generate 'commonwealth_vlr_engine:install --force'
  end

  def configure_test_assets
    insert_into_file 'config/environments/test.rb', after: 'Rails.application.configure do' do
      "\nconfig.assets.check_precompiled_asset = false"
    end
  end

  def set_up_solr
    generate 'commonwealth_vlr_engine:solr'
  end
end
