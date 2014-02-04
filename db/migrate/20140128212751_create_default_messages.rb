class CreateDefaultMessages < ActiveRecord::Migration
  def change
    create_table :default_messages do |t|
      t.string :message

      t.timestamps
    end
  end
end
