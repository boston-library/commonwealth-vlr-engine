# frozen_string_literal: true

# various app-specific config settings
# use file name "a_load_commonwealth_vlr_configs" so Rails loads this file before other initializers

ASSET_STORE = Rails.application.config_for('asset_store')

GOOGLE_ANALYTICS = Rails.application.config_for('google_analytics')

CONTACT_EMAILS = Rails.application.config_for('contact_emails')

IIIF_SERVER = Rails.application.config_for('iiif_server')

GEOJSON_STATIC_FILE = Rails.application.config_for('geojson_static_file')

CURATOR = Rails.application.config_for('curator')