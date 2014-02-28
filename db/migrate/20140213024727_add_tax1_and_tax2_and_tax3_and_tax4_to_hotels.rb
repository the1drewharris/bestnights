class AddTax1AndTax2AndTax3AndTax4ToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :tax1, :string
    add_column :hotels, :tax2, :string
    add_column :hotels, :tax3, :string
    add_column :hotels, :tax4, :string
  end
end
