# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Media
    class BookViewerComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

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
