class AddRoomIdToRoomPhotos < ActiveRecord::Migration
  def change
    add_column :room_photos, :room_id, :string
  end
end
