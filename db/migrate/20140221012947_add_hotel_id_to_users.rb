class AddHotelIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hotel_id, :string
  end
end
