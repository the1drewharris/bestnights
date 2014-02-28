class ChangeDescriptionFieldInHotel < ActiveRecord::Migration
  def change
    change_column :hotels, :description, :text    
  end
end
