class AddNightNumberToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :night_number, :integer
  end
end
