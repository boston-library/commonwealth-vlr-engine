# CommonwealthVlrEngine

A plugin for Blacklight that provides base functionality for virtual local repositories (VLRs) pulling content from the main [Digital Commonwealth](http://digitalcommonwealth.org) repository managed by the Boston Public Library.

More documentation coming soon. This project is currently in high development and in a very beta state.

For now, check out some [slides on this concept](https://goo.gl/GysxNK) presented at [Open Repositories 2015](https://www.conftool.com/or2015/index.php?page=browseSessions&form_session=49).

# Temporary Install Instructions

  rails new <app_name>
  cd <app_name>
  Add the following to your Gemfile:
    #various utilities
    gem 'libv8', '~> 3.16.14.3'

    # blacklight
    gem 'blacklight', '5.13.1'
    gem 'rsolr', '~> 1.0.6'
    gem 'commonwealth-vlr-engine', :git => 'https://github.com/boston-library/commonwealth-vlr-engine'
  bundle install
  rails generate blacklight:install
  rails g commonwealth_vlr_engine:install
  <configure_yml_files>
