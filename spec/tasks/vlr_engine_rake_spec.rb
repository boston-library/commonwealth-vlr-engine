require 'rails_helper'
require 'rake'

describe 'vlr_engine namespace rake tasks' do
  time = Time.now.to_f
  before :all do
    Rake.application.rake_require '../tasks/vlr_engine'
    Rake::Task.define_task(:environment)
  end

  describe 'vlr_engine:create_geojson' do
    let(:run_rake_task) do
      Rake::Task['vlr_engine:create_geojson'].reenable
      Rake.application.invoke_task 'vlr_engine:create_geojson'
    end
    let(:file_path) { "#{Rails.root}/#{GEOJSON_STATIC_FILE['filepath']}" }

    it 'creates the geojson file' do
      run_rake_task
      expect(File.file?(file_path)).not_to be_nil
      expect(File.stat(file_path).mtime.to_f).to be > time
    end
  end
end
