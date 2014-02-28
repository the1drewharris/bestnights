class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :hotel
      t.references :room_type
      t.string :name
      t.string :description
      t.string :price
      t.string :description
      t.string :additionaladultfee
      t.string :orginal_price
      
      t.timestamps
    end
  end
end
