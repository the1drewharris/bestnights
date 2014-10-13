class AddHotelIdToRoomSubTypes < ActiveRecord::Migration
  def change
  	add_column :room_sub_types, :hotel_id, :integer
  end
end
