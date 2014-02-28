class RemovePaperclipfilefieldsFromHotelPhotos < ActiveRecord::Migration
  def up
    remove_column :hotel_photos, :paperclipfilefields
  end

  def down
    add_column :hotel_photos, :paperclipfilefields, :string
  end
end
