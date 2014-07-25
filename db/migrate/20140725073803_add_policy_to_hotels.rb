class AddPolicyToHotels < ActiveRecord::Migration
  def change
  	add_column  :hotels, :policy,        :text
  	add_column  :hotels, :phone,        :string
  end
end
