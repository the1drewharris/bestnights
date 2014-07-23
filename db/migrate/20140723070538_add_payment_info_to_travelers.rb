class AddPaymentInfoToTravelers < ActiveRecord::Migration
  def change
  	add_column  :travelers, :credit_card_type,        :string
  	add_column  :travelers, :credit_card_number,      :string
  	add_column  :travelers, :ccv,                     :string
  	add_column  :travelers, :credit_card_expiry_date, :date
  end
end
