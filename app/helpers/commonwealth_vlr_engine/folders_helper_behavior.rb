module CommonwealthVlrEngine
  module FoldersHelperBehavior

    def folder_belongs_to_user
      current_or_guest_user.folders.include? @folder
    end

  end
end