class CreateHotelPhotos < ActiveRecord::Migration
  def change
    create_table :hotel_photos do |t|
      t.references :hotel
      t.string :paperclipfilefields


      t.timestamps
    end
  end
end
