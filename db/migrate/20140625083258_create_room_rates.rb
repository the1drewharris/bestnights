class CreateRoomRates < ActiveRecord::Migration
  def change
    create_table :room_rates do |t|
      t.integer :room_id
      t.integer :room_type_id
      t.float :rate_monday
      t.float :rate_tuesday
      t.float :rate_wednesday
      t.float :rate_thursday
      t.float :rate_friday
      t.float :rate_saturday
      t.float :rate_sunday

      t.timestamps
    end
  end
end
