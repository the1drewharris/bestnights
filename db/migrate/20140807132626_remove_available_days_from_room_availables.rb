class RemoveAvailableDaysFromRoomAvailables < ActiveRecord::Migration
	def change
		remove_column :room_availables, :days
		remove_column :room_availables, :availables_days
	end
end
