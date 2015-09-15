require 'spec_helper'
require 'rake'

describe 'vlr_engine namespace rake tasks' do

  before :all do
    Rake.application.rake_require '../tasks/vlr_engine'
    Rake::Task.define_task(:environment)
    @time = Time.now.to_f
  end

  describe 'vlr_engine:create_geojson' do

    let :run_rake_task do
      Rake::Task['vlr_engine:create_geojson'].reenable
      Rake.application.invoke_task 'vlr_engine:create_geojson'
      @file_path = "#{Rails.root.to_s}/#{GEOJSON_STATIC_FILE['filepath']}"
    end

    it 'should create the geojson file' do
      run_rake_task
      expect(File.file?(@file_path)).not_to be_nil
      expect(File.stat(@file_path).mtime.to_f).to be > @time
    end

  end

end