class AddFaxToContactPeople < ActiveRecord::Migration
  def change
  	add_column :contact_people, :fax, :string
  end
end
