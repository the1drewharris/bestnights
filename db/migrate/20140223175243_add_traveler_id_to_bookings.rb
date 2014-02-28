class AddTravelerIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :traveler_id, :string
  end
end
