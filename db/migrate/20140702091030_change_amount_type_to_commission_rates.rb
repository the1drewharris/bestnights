class ChangeAmountTypeToCommissionRates < ActiveRecord::Migration
  def up
  	change_column :commission_rates, :amount, :float
  end

  def down
  	change_column :commission_rates, :amount, :string
  end
end
