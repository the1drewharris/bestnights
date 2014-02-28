class AddFirstnameAndLastnameAndAddress1AndAddress2AndStateIdAndCountryIdAndZipAndPhoneNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :state_id, :integer
    add_column :users, :country_id, :integer
    add_column :users, :zip, :string
    add_column :users, :phone_number, :string
  end
end
