class CreateSiteContacts < ActiveRecord::Migration
  def change
    create_table :site_contacts do |t|
    	t.string		:phone_number
    	t.string		:fax
    	t.string		:email
    	t.text			:address
      t.timestamps
    end
  end
end
