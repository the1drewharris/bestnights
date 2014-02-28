class RemoveHotelIdFromHotelAttributes < ActiveRecord::Migration
  def up
    remove_column :hotel_attributes, :hotel_id
  end

  def down
    add_column :hotel_attributes, :hotel_id, :string
  end
end
