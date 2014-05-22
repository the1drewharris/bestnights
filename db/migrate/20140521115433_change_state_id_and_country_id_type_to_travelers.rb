class ChangeStateIdAndCountryIdTypeToTravelers < ActiveRecord::Migration
  def up
  	change_column :travelers, :state_id, :string
    change_column :travelers, :country_id, :string
  end

  def down
  	change_column :travelers, :state_id, :integer
    change_column :travelers, :country_id, :integer
  end
end
