class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.references :country
      t.string :state_province
      t.string :abbreviation


      t.timestamps
    end
  end
end
