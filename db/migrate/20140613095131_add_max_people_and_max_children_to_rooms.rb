class AddMaxPeopleAndMaxChildrenToRooms < ActiveRecord::Migration
  def change
  	add_column :rooms, :max_people, :integer
  	add_column :rooms, :max_children, :integer
  	add_column :rooms, :room_size, :string
  end
end
