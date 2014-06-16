class ChangeStateIdAndCountryIdToUsers < ActiveRecord::Migration
  def up
  	change_column :users, :state_id, :string
  	change_column :users, :country_id, :string
  end

  def down
  	change_column :users, :state_id, :integer
  	change_column :users, :country_id, :integer
  end
end
