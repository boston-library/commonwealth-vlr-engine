module CommonwealthVlrEngine
  module FoldersHelperBehavior

    def folder_belongs_to_user
      if current_or_guest_user.folders.include? @folder
        true
      else
        false
      end
    end

  end
end