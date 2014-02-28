class AddCountryIdToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :country_id, :string
  end
end
