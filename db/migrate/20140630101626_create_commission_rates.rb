class CreateCommissionRates < ActiveRecord::Migration
  def change
    create_table :commission_rates do |t|
      t.string :amount

      t.timestamps
    end
  end
end
