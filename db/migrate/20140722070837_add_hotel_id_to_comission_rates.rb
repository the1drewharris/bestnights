class AddHotelIdToComissionRates < ActiveRecord::Migration
  def change
  	add_column :commission_rates, :hotel_id, :integer
  end
end
