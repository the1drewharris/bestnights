class CreateRoomRateDetails < ActiveRecord::Migration
  def change
    create_table :room_rate_details do |t|
    	t.string 		:day
    	t.string	:status
    	t.string	:rate_per_night
    	t.integer	:booked
    	t.integer	:canceled
    	t.string	:policy_group
    	t.string	:month
    	t.string 	:year
    	t.date		:day
    	t.date 		:from_date
    	t.date 		:to_date
    	t.integer	:rooms_to_sell
    	t.integer	:room_id

      t.timestamps
    end
  end
end
