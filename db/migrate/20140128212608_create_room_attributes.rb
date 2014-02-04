class CreateRoomAttributes < ActiveRecord::Migration
  def change
    create_table :room_attributes do |t|
      t.string :attr	

      t.timestamps
    end
  end
end
