class CreateRoomPrices < ActiveRecord::Migration
  def change
    create_table :room_prices do |t|
      t.references :hotel
      t.references :room_type
      t.string :price
      t.string :additionaladultfee
      t.string :original_price


      t.timestamps
    end
  end
end
