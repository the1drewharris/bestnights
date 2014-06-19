class CreateRateCategories < ActiveRecord::Migration
  def change
    create_table :rate_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
