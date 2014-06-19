class ChangeRoomIdToRates < ActiveRecord::Migration
  def up
  	change_column :rates, :room_id, :string
  end

  def down
  	change_column :rates, :room_id, :integer
  end
end
