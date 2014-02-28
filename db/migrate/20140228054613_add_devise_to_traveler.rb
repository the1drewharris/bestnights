class AddDeviseToTraveler < ActiveRecord::Migration
  def change
    add_column :travelers, :encrypted_password, :string
    add_column :travelers, :reset_password_token, :string
    add_column :travelers, :reset_password_sent_at, :string
    add_column :travelers, :sign_in_count, :integer, :default => 0, :null => false
    add_column :travelers, :current_sign_in_at, :datetime
    add_column :travelers, :last_sign_in_at, :datetime
    add_column :travelers, :current_sign_in_ip, :string
    add_column :travelers, :last_sign_in_ip, :string
  end
end
