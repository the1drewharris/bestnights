class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :hotel
      t.string :review
      t.string :status	

      t.timestamps
    end
  end
end
