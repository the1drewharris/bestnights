class AddStartingInventoryToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :starting_inventory, :integer
  end
end
