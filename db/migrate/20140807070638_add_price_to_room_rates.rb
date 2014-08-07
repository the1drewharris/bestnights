class AddPriceToRoomRates < ActiveRecord::Migration
  def change
  	remove_column :room_rates, :room_id
  	add_column 		:room_rates, :price, :float
  end
end
