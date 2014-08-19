class CreateRoomSubTypes < ActiveRecord::Migration
  def change
    create_table :room_sub_types do |t|
      t.string :name
      t.integer :room_type_id

      t.timestamps
    end
  end
end
