class AddTax1LabelAndTax2LabelAndTax3LabelAndTax4LabelToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :tax1_label, :string
    add_column :hotels, :tax2_label, :string
    add_column :hotels, :tax3_label, :string
    add_column :hotels, :tax4_label, :string
  end
end
