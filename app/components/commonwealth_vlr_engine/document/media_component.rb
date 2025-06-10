# frozen_string_literal: true

# wrapper for various media display components
module CommonwealthVlrEngine
  module Document
    class MediaComponent < ViewComponent::Base
      def initialize(document:, object_files:)
        @document = document
        @object_files = object_files
      end
      attr_reader :document, :object_files

      IMAGE_VIEWER_LIMIT = 7

      # def single_image_viewer
      #   render CommonwealthVlrEngine::Media::SingleImageViewerComponent.new(document: document, object_files: object_files)
      # end
      renders_one :single_image_viewer, -> do
        CommonwealthVlrEngine::Media::SingleImageViewerComponent.new(document: document, object_files: object_files)
      end

      renders_one :multi_image_viewer, -> do
        CommonwealthVlrEngine::Media::MultiImageViewerComponent.new(document: document, object_files: object_files)
      end

      renders_one :pdf_viewer, -> do
        CommonwealthVlrEngine::Media::PdfViewerComponent.new(document: document, object_files: object_files)
      end

      renders_one :audio_player, -> do
        CommonwealthVlrEngine::Media::AudioPlayerComponent.new(document: document, object_files: object_files)
      end

      renders_one :video_player, -> do
        CommonwealthVlrEngine::Media::VideoPlayerComponent.new(document: document, object_files: object_files)
      end

      def render?
        true # logic TK
      end

      # Hack so that the default lambdas are triggered
      # so that we don't have to do c.with_top_bar() in the call.
      def before_render
        set_slot(:single_image_viewer, nil)
        set_slot(:multi_image_viewer, nil)
        set_slot(:pdf_viewer, nil)
        set_slot(:audio_player, nil)
        set_slot(:video_player, nil)
      end
    end
  end
end
