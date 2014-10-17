class CreateHotelViews < ActiveRecord::Migration
  def change
    create_table :hotel_views do |t|
    	t.integer :hotel_id

      t.timestamps
    end
  end
end
