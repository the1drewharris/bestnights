class AddAdditionalAdultToRooms < ActiveRecord::Migration
  def change
  	add_column	:rooms, :aditionaladults, :integer
  end
end
