class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :country
      t.string :abbreviation	

      t.timestamps
    end
  end
end
