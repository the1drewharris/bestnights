class AddHotelIdToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :hotel_id, :string
  end
end
