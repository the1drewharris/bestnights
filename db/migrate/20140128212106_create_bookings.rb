class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :hotel
      t.references :room_type
      t.string :price
      t.datetime :from_date
      t.datetime :to_date
      t.integer :adults
      t.integer :children 	

      t.timestamps
    end
  end
end
