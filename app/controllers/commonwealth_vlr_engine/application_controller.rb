module CommonwealthVlrEngine
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    helper Openseadragon::OpenseadragonHelper

    layout 'commonwealth-vlr-engine'
  end
end
