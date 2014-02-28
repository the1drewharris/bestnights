class ChangeFromDateAndToDateFormatInBookings < ActiveRecord::Migration
  def up
    change_column :bookings, :from_date, :date
    change_column :bookings, :to_date, :date
  end

  def down
    change_column :bookings, :from_date, :datetime
    change_column :bookings, :to_date, :datetime
  end
end
