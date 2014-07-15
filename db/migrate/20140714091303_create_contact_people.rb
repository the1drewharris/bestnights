class CreateContactPeople < ActiveRecord::Migration
  def change
    create_table :contact_people do |t|
    	t.integer	:hotel_id
    	t.string 	:name
    	t.string	:title
    	t.string	:designation
    	t.string	:gender
    	t.string	:email
    	t.string	:phone_number
    	t.string	:mobile_number
    	t.text		:address
    	t.string	:postal_code
    	t.string	:city
    	t.string	:country
        t.text      :description


      t.timestamps
    end
  end
end

