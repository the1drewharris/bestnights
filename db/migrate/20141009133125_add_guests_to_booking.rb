class AddGuestsToBooking < ActiveRecord::Migration
  def change
  	add_column	:bookings, :guests, :integer
  end
end
