# various app-specific config settings
# use file name "a_load_commonwealth_vlr_configs" so Rails loads this file before other initializers

ASSET_STORE = YAML.load_file(Rails.root.join('config', 'asset_store.yml'))[Rails.env]

GOOGLE_ANALYTICS = YAML.load_file(Rails.root.join('config', 'google_analytics.yml'))[Rails.env]

CONTACT_EMAILS = YAML.load_file(Rails.root.join('config', 'contact_emails.yml'))[Rails.env]

IIIF_SERVER = YAML.load_file(Rails.root.join('config', 'iiif_server.yml'))[Rails.env]

GEOJSON_STATIC_FILE = YAML.load_file(Rails.root.join('config', 'geojson_static_file.yml'))[Rails.env]

SECRETS = YAML.load_file(Rails.root.join('config', 'secrets.yml'))[Rails.env]

CURATOR = YAML.load_file(Rails.root.join('config', 'curator.yml'))[Rails.env]