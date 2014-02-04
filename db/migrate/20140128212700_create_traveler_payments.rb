class CreateTravelerPayments < ActiveRecord::Migration
  def change
    create_table :traveler_payments do |t|
      t.string :transactionid
      t.string :amount

      t.timestamps
    end
  end
end
