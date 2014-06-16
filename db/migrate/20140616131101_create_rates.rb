class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
    	t.string	 :day
    	t.string	 :category
    	t.integer	 :hotel_id
    	t.date		 :from_date
    	t.date 		 :to_date
    	t.string 	 :price
    	
      t.timestamps
    end
  end
end
