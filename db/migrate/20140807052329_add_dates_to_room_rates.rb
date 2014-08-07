class AddDatesToRoomRates < ActiveRecord::Migration
  def change
  	remove_column :room_rates, :rate_monday
  	remove_column :room_rates, :rate_tuesday
  	remove_column :room_rates, :rate_wednesday
  	remove_column :room_rates, :rate_thursday
  	remove_column :room_rates, :rate_friday
  	remove_column :room_rates, :rate_saturday
  	remove_column :room_rates, :rate_sunday
  	add_column 		:room_rates, :from_date, :date
  	add_column 		:room_rates, :to_date, :date
  end
end
