class AddRoomIdToRates < ActiveRecord::Migration
  def change
  	add_column :rates, :room_id, :integer
  end
end
