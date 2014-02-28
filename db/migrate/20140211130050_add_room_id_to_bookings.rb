class AddRoomIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :room_id, :string
  end
end
