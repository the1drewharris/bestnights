class CreateRoomStatuses < ActiveRecord::Migration
  def change
    create_table :room_statuses do |t|
      t.integer :room_type_id
      t.boolean :status
      t.date :from_date
      t.date :to_date

      t.timestamps
    end
  end
end
