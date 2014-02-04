class CreateHotelAttributes < ActiveRecord::Migration
  def change
    create_table :hotel_attributes do |t|
      t.string :attr
      
      t.timestamps
    end
  end
end
