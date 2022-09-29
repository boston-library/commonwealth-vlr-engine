# frozen_string_literal: true

require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  def remove_index
    remove_file 'public/index.html'
  end

  def set_env_vars
    env_vars = %q(VLR_SITE_ID=commonwealth
VLR_INSTITUTION_PID=bpl-dev:abcd12345
GEOJSON_PATH=lib/assets/static_geojson_catalog-map.json
IIIF_URL=https://iiif-dc3dev.bpl.org/iiif/2/
AZURE_STORAGE_ACCOUNT_NAME=bpltestaccount
AZURE_STORAGE_ACCOUNT_ENDPOINT=https://$AZURE_STORAGE_ACCOUNT_NAME.blob.core.windows.net
CURATOR_API_URL=https://curator-dc3dev.bpl.org/api
RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
RECAPTCHA_SECRET_KEY=6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
    )
    File.open('.env', 'w') { |f| f.write(env_vars) }
  end

  def run_vlr_engine_install
    generate 'commonwealth_vlr_engine:install --force'
  end

  def set_up_solr
    generate 'commonwealth_vlr_engine:solr'
  end
end
