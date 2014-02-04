class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.references :state
      t.string :name
      t.string :description
      t.string :address1
      t.string :address2
      t.string :city
      t.string :zip

      t.timestamps
    end
  end
end
