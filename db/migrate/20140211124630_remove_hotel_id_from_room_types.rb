class RemoveHotelIdFromRoomTypes < ActiveRecord::Migration
  def change
    remove_column :room_types, :hotel_id
  end
  
  def up
    remove_column :room_types, :hotel_id
  end

  def down
    add_column :room_types, :hotel_id, :string
  end
end
