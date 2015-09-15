# CommonwealthVlrEngine

[![Coverage Status](https://coveralls.io/repos/boston-library/commonwealth-vlr-engine/badge.svg?branch=master&service=github)](https://coveralls.io/github/boston-library/commonwealth-vlr-engine?branch=master)

A virtual local repository is an application that provides digital object discovery and display functionality without the overhead of actual asset management, pulling content via APIs from a larger repository managed elsewhere. The subset of content to be displayed can be based on any valid repository search or facet query parameters for descriptive, administrative, or technical metadata.

Commonwealth-VLR-Engine is a Rails engine for creating a [Blacklight](https://github.com/projectblacklight/blacklight) app that provides access to content from Solr/Fedora, packaging a number of feature-rich enhancements and modifications, including [Blacklight Gallery](https://github.com/projectblacklight/blacklight-gallery), [Blacklight Advanced Search](https://github.com/projectblacklight/blacklight_advanced_search), [Blacklight Maps](https://github.com/projectblacklight/blacklight-maps), and [OpenSeadragon](https://github.com/IIIF/openseadragon-rails). Via a simple install process, adopters can quickly deploy a customizable 'turn-key' application that presents objects from the Digital Commonwealth repository (managed by the Boston Public Library) using their own branding.

More documentation coming soon. This project is currently in high development and in a very beta state.

For now, check out some [slides on this concept](https://goo.gl/GysxNK) presented at [Open Repositories 2015](https://www.conftool.com/or2015/index.php?page=browseSessions&form_session=49).

To view this engine in action, check out [Digital Commonwealth](https://digitalcommonwealth.org).

## Install Instructions
Create a new Rails app:
```
$ rails new app_name
$ cd app_name
```
Add Blacklight and Commonwealth-VLR-Engine to your Gemfile:
```ruby
gem 'blacklight'
gem 'commonwealth-vlr-engine', :git => 'https://github.com/boston-library/commonwealth-vlr-engine'
```
Then run the install:
```
$ rails generate blacklight:install
$ rails generate commonwealth_vlr_engine:install
$ rake db:migrate
```
You will then need to configure various YAML files to point to existing Solr, Fedora, and IIIF image servers.
