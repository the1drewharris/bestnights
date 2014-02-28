class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :rooms, :orginal_price, :original_price
  end
end
