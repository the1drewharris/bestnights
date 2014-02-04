class CreateHotels < ActiveRecord::Migration
  def change
    create_table :hotels do |t|
      t.references :state
      t.string :name
      t.string :description
      t.string :address1
      t.string :city
      t.string :zip

      t.timestamps
    end
  end
end
