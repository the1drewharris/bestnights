class AddTravelerIdToTravelerPayments < ActiveRecord::Migration
  def change
    add_column :traveler_payments, :traveler_id, :integer
  end
end
