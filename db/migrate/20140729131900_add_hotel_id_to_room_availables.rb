class AddHotelIdToRoomAvailables < ActiveRecord::Migration
  def change
  	add_column  :room_availables, :hotel_id, :integer
  end
end
