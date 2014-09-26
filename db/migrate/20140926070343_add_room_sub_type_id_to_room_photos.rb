class AddRoomSubTypeIdToRoomPhotos < ActiveRecord::Migration
  def change
  	add_column	:room_photos, :room_sub_type_id, :integer
  end
end
