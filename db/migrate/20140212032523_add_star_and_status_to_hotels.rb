class AddStarAndStatusToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :star, :string
    add_column :hotels, :status, :string
  end
end
