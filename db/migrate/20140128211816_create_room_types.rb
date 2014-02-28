class CreateRoomTypes < ActiveRecord::Migration
  def change
    create_table :room_types do |t|
      t.references :hotel
      t.string :room_type

      t.timestamps
    end
  end
end
