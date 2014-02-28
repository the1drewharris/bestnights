class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string   :coupon_code
      t.datetime :expiry_date
      t.datetime :start_date
      t.integer  :transaction_item
      t.string   :percent
      t.decimal  :discount
      t.integer  :times_allowed
      t.timestamps
    end
  end
end
