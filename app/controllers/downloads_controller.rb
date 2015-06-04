class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def can_download?
    datastream.dsid == 'productionMaster'
  end

end