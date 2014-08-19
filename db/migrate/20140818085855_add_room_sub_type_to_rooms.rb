class AddRoomSubTypeToRooms < ActiveRecord::Migration
  def change
  	add_column :rooms, :room_sub_type_id, :integer
  end
end
