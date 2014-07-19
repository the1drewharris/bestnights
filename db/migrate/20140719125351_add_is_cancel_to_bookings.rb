class AddIsCancelToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :is_cancel, :boolean, default: false
  end
end
