module CommonwealthVlrEngine
  module ImageViewerHelperBehavior

    # return id for the book object, or parent book if @document is a volume
    def book_id(document)
      if document[:is_volume_of_ssim]
        document[:is_volume_of_ssim].first
      else
        document.id
      end
    end

  end
end