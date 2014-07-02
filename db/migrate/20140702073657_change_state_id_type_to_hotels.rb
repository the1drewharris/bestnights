class ChangeStateIdTypeToHotels < ActiveRecord::Migration
  def up
  	change_column :hotels, :state_id, :string
  end

  def down
  	change_column :hotels, :state_id, :integer
  end
end
