class RemoveRoomTypeIdFromAvailabilities < ActiveRecord::Migration
  def up
    remove_column :availabilities, :room_type_id
  end

  def down
    add_column :availabilities, :room_type_id, :integer
  end
end
