class RemovePaperclipfilefieldsFromRoomPhotos < ActiveRecord::Migration
  def change 
    remove_column :room_photos, :paperclipfilefields
  end
end
