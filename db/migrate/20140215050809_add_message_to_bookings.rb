class AddMessageToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :message, :text
  end
end
