class AddStartingInventoryToAvailability < ActiveRecord::Migration
  def change
    add_column :availabilities, :starting_inventory, :integer
  end
end
