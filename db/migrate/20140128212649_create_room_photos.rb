class CreateRoomPhotos < ActiveRecord::Migration
  def change
    create_table :room_photos do |t|
      t.references :hotel
      t.string :paperclipfilefields


      t.timestamps
    end
  end
end
