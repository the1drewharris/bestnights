class ChangeRoomTypeIdToRoomAvailables < ActiveRecord::Migration
  def up
  	change_column :room_availables, :room_type_id, :string
  end

  def down
  	change_column :room_availables, :room_type_id, :integer
  end
end
