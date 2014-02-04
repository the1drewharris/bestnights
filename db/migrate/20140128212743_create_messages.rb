class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.string :sender_id
      t.string :sender_type
      t.string :to_id
      t.string :to_type
      t.string :type
      t.string :status

      t.timestamps
    end
  end
end
