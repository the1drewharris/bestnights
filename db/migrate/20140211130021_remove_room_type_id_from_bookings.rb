class RemoveRoomTypeIdFromBookings < ActiveRecord::Migration
  def up
    remove_column :bookings, :room_type_id
  end

  def down
    add_column :bookings, :room_type_id, :integer
  end
end
