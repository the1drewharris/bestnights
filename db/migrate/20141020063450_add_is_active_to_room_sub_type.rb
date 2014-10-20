class AddIsActiveToRoomSubType < ActiveRecord::Migration
  def change
  	add_column :room_sub_types, :is_active, :boolean, default: true
  end
end
