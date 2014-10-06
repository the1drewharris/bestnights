class AddMessageToContacts < ActiveRecord::Migration
  def change
  	add_column	:contacts, :message, :text
  end
end
