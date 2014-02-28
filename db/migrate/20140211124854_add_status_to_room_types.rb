class AddStatusToRoomTypes < ActiveRecord::Migration
  def change
    add_column :room_types, :status, :string
  end
end
