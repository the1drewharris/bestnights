class AddHotelIdToHotelAttributes < ActiveRecord::Migration
  def change
    add_column :hotel_attributes, :hotel_id, :string
  end
end
