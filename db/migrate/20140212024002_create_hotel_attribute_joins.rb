class CreateHotelAttributeJoins < ActiveRecord::Migration
  def change
    create_table :hotel_attribute_joins do |t|
      t.references :hotel
      t.references :hotel_attribute
      
      t.timestamps
    end
  end
end
