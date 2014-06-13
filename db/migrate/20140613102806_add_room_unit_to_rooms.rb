class AddRoomUnitToRooms < ActiveRecord::Migration
  def change
  	add_column :rooms, :room_unit, :string
  end
end
