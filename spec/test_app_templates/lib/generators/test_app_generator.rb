# frozen_string_literal: true

require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  def remove_index
    remove_file 'public/index.html'
  end

  def set_env_vars
    env_vars = %q(VLR_SITE_ID=commonwealth
VLR_INSTITUTION_PID=bpl-dev:abcd12345
FEDORA_URL=https://fedoradev.bpl.org/fedora
GEOJSON_PATH=lib/assets/static_geojson_catalog-map.json
IIIF_URL=https://iiifdev.bpl.org/iiif/2/
    )
    File.open('.env', 'w') { |f| f.write(env_vars) }
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
