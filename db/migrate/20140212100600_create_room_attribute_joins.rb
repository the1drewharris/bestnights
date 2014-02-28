class CreateRoomAttributeJoins < ActiveRecord::Migration
  def change
    create_table :room_attribute_joins do |t|
      t.references :room
      t.references :room_attribute

      t.timestamps
    end
  end
end
