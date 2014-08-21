class AddRoomSubTypeToRoomStatuses < ActiveRecord::Migration
  def change
  	add_column :room_statuses, :room_sub_type_id, :integer
  end
end
