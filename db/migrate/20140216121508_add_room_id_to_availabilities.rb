class AddRoomIdToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :room_id, :string
  end
end
