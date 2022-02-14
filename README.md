# CommonwealthVlrEngine

[![Coverage Status](https://coveralls.io/repos/boston-library/commonwealth-vlr-engine/badge.svg?branch=master&service=github)](https://coveralls.io/github/boston-library/commonwealth-vlr-engine?branch=master)

---
**⚠️IMPORTANT!**

This branch (`bpl-mapportal-on-dc3`) is a fork to support using the Leventhal Map & Education Center [bpl-mapportal](https://github.com/boston-library/bpl-mapportal) application with the BPL DC3 repository environment.

This branch should ONLY be used with bpl-mapportal, which is running Blacklight 6.3.3. The BPL Repository Services team does not have the resources at the moment to undertake a full upgrade of the bpl-mapportal app to the latest Blacklight, GeoBlacklight, Bootstrap, and commonwealth-vlr-engine dependencies. This fork is a temporary "shim."

The specs on this branch do NOT pass, no work has been done for this yet (and may never be).

---

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
Add Blacklight to your Gemfile:
```ruby
gem 'blacklight', '~>5.14.0'
```
Run the Blacklight install:
```
$ rails generate blacklight:install
```
Then add Commonwealth-VLR-Engine to your Gemfile:
```ruby
gem 'commonwealth-vlr-engine', :git => 'https://github.com/boston-library/commonwealth-vlr-engine'
```
Run the VLR-Engine install:
```
$ rails generate commonwealth_vlr_engine:install
$ rake db:migrate
```
You will then need to configure various YAML files to point to existing Solr, Fedora, and IIIF image servers.

## Blacklight Version Compatibility
The table below indicates which versions of Commonwealth-VLR-Engine are compatible with which versions of Blacklight.

VLR-Engine version | works with Blacklight version
----------------------- | ---------------------
0.0.7 | >= 6.3.0 to < 7.*
0.0.2 | >= 6.1.0 to < 6.3
0.0.1 | >= 5.14.0 to < 6.*  