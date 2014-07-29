class AddAvailableDaysToRoomAvailables < ActiveRecord::Migration
  def change
  	add_column  :room_availables, :availables_days, :string
  end
end
