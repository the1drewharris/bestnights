class RemoveRoomIdFromRoomAvailables < ActiveRecord::Migration
  def change
		remove_column :room_availables, :room_id
		remove_column :room_availables, :status
	end
end
