class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.references :hotel

      t.string :comission_rate
      t.string :status


      t.timestamps
    end
  end
end
