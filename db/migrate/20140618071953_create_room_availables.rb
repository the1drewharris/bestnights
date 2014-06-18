class CreateRoomAvailables < ActiveRecord::Migration
  def change
    create_table :room_availables do |t|
      t.integer :room_id
      t.integer :room_type_id
      t.boolean :status
      t.date :from_date
      t.date :to_date
      t.string :days
      t.integer :number

      t.timestamps
    end
  end
end
