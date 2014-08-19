class AddRoomSubTypeIdToRoomAvailables < ActiveRecord::Migration
  def change
  	add_column :room_availables, :room_sub_type_id, :integer
  end
end
