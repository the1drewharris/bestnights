class AddBasePriceToRoomTypes < ActiveRecord::Migration
  def change
  	add_column  :room_types, :base_price, :float
  end
end
