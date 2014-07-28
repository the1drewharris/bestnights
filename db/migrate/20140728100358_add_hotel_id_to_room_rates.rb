class AddHotelIdToRoomRates < ActiveRecord::Migration
  def change
  	add_column  :room_rates, :hotel_id, :integer
  end
end
