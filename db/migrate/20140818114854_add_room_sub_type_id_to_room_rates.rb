class AddRoomSubTypeIdToRoomRates < ActiveRecord::Migration
  def change
  	add_column :room_rates, :room_sub_type_id, :integer
  end
end
