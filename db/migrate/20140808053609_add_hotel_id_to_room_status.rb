class AddHotelIdToRoomStatus < ActiveRecord::Migration
  def change
  	add_column 		:room_statuses, :hotel_id, :integer
  end
end
