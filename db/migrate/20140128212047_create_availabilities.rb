class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.references :room_type
      t.datetime :from_date
      t.datetime :to_date
      t.integer :count	

      t.timestamps
    end
  end
end
