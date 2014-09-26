class AddNameAndPhoneNumberToContacts < ActiveRecord::Migration
  def change
  	add_column	:contacts, :name, :string
  	add_column	:contacts, :phone_number, :string
  end
end
