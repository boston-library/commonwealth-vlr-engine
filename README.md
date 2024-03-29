# CommonwealthVlrEngine

[![Build Status](https://travis-ci.com/boston-library/commonwealth-vlr-engine.svg?branch=master)](https://travis-ci.com/boston-library/commonwealth-vlr-engine) [![Coverage Status](https://coveralls.io/repos/boston-library/commonwealth-vlr-engine/badge.svg?branch=master&service=github)](https://coveralls.io/github/boston-library/commonwealth-vlr-engine?branch=master)

A virtual local repository is an application that provides digital object discovery and display functionality without the overhead of actual asset management, pulling content via APIs from a larger repository managed elsewhere. The subset of content to be displayed can be based on any valid repository search or facet query parameters for descriptive, administrative, or technical metadata.

Commonwealth-VLR-Engine is a Rails engine for creating a [Blacklight](https://github.com/projectblacklight/blacklight) app that provides access to content from Solr, packaging a number of feature-rich enhancements and modifications, including [Blacklight Gallery](https://github.com/projectblacklight/blacklight-gallery), [Blacklight Advanced Search](https://github.com/projectblacklight/blacklight_advanced_search), [Blacklight Maps](https://github.com/projectblacklight/blacklight-maps), and [OpenSeadragon](https://github.com/IIIF/openseadragon-rails). Via a simple install process, adopters can quickly deploy a customizable 'turn-key' application that presents objects from the Digital Commonwealth repository (managed by the Boston Public Library) using their own branding.

To view this engine in action, check out [Digital Commonwealth](https://digitalcommonwealth.org).

## Install Instructions
Create a new Rails app:
```
$ rails new app_name
$ cd app_name
```
Add Commonwealth-VLR-Engine to your Gemfile:
```ruby
gem 'commonwealth-vlr-engine', git: 'https://github.com/boston-library/commonwealth-vlr-engine'
```
Run the VLR-Engine install:
```
$ bundle install
$ rails generate commonwealth_vlr_engine:install
# Note: if you want to include user functionality (bookmarks, folders, saved searches, etc) via Devise and Bpluser use:
# $ rails generate commonwealth_vlr_engine:install --bpluser
$ rake db:migrate
```
You will then need to configure various ENV vars to point to existing Solr, Fedora, and IIIF image servers.
(See `.env.example` generated into your app's home directory.)

The installer will ask to overwrite your app's local `config/locales/blacklight.en.yml` (and `config/locales/devise.en.yml` if you run the install with `--bpluser`).
If you choose not to overwrite these files during the installation, you can refer to `lib/generators/commonwealth_vlr_engine/templates/config` for an example of what values are expected in your app.

## Blacklight Version Compatibility
The table below indicates which versions of Commonwealth-VLR-Engine are compatible with which versions of Blacklight.

VLR-Engine version | works with Blacklight version
----------------------- | ---------------------
0.1.0 | >= 7.12.1 to < 8.*
0.0.7 | >= 6.3.0 to < 7.*
0.0.2 | >= 6.1.0 to < 6.3
0.0.1 | >= 5.14.0 to < 6.*

## Development / Testing

After cloning the repository, and running `bundle install`, run `bundle exec rake` from the project's root directory, which will:
1. Generate the test application at `.internal_test_app`
2. Run `Blacklight` and `CommonwealthVlrEngine` generators
3. Start Solr and index the sample Solr docs from `spec/fixtures`
4. Run all specs

### Useful Development commands

Generate the test application at `.internal_test_app`:
```
$ rake engine_cart:generate
```

Destroy the test application at `.internal_test_app`:
```
$ rake engine_cart:clean
```
Start Solr (run in new terminal from `.internal_test_app` home):
```
$ solr_wrapper
```
Stop Solr:
```
Ctrl-C
```
Purge Solr (Solr must be running):
```
$ solr_wrapper clean
```
Index sample Solr docs (run from `internal_test_app`):
```
# Solr must be running
$ RAILS_ENV=test bundle exec rake commonwealth_vlr_engine:test_index:seed
```
Run specs (Solr must be running):
```
# run all tests
$ bundle exec rake spec
# run a single spec
$ bundle exec rake spec SPEC=./spec/models/some_model_spec.rb # run one spec
```
