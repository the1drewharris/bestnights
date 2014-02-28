class AddUserIdToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :user_id, :string
  end
end
