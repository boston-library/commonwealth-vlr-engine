# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# this file was used to test a task: vlr_engine:create_geojson
# to create a static GeoJSON file using Blacklight::Maps
# keep as a placeholder until that gem is updated
RSpec.describe 'vlr_engine namespace rake tasks' do
  before :all do
    Rake.application.rake_require '../tasks/vlr_engine'
    Rake::Task.define_task(:environment)
  end
end
