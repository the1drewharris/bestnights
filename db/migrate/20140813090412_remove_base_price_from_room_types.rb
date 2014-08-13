class RemoveBasePriceFromRoomTypes < ActiveRecord::Migration
  def change
		remove_column :room_types, :base_price
	end
end
