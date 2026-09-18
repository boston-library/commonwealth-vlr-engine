# frozen_string_literal: true

module CommonwealthVlrEngine
  module Media
    class BookViewerComponent < CommonwealthVlrEngine::Document::MediaComponent
      # override a few defaults as needed
      def uv_config
        {
          options: { 'clickToZoomEnabled' => true,
                     'zoomToSearchResultEnabled' => true },
          modules: {
            # centerPanel options doesn't seem to work, hiding title via CSS for now
            # 'centerPanel' => { options: { 'titleEnabled' => false } },
            'openSeadragonCenterPanel' => { options: { 'showAdjustImageControl' => false } },
            'shareDialogue' => { options: { 'embedEnabled' => false } }
          }
        }.to_json
      end

      def render?
        helpers.include_uv?(document, object_files)
      end
    end
  end
end
