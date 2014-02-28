class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :card_type
      t.string :card_number
      t.string :ccid
      t.datetime :expiration
      
      t.timestamps
    end
  end
end
