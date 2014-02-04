class CreateTravelers < ActiveRecord::Migration
  def change
    create_table :travelers do |t|
      t.references :state
      t.references :country
      t.string :firstname
      t.string :lastname
      t.string :address1
      t.string :address2
      t.string :city
      t.string :zip
      t.string :email
      t.string :phone_number

      t.timestamps
    end
  end
end
