class AddLunchAndDinnerToRooms < ActiveRecord::Migration
  def change
  	add_column :rooms, :lunch, :boolean, :default => false 
  	add_column :rooms, :dinner, :boolean, :default => false
  	add_column :rooms, :all_inclusive, :boolean, :default => false
  end
end
