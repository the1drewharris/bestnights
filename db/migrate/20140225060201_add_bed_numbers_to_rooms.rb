class AddBedNumbersToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :bed_numbers, :integer
  end
end
