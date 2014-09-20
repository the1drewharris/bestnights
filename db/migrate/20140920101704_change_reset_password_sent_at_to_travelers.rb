class ChangeResetPasswordSentAtToTravelers < ActiveRecord::Migration
def up
  	change_column :travelers, :reset_password_sent_at, :datetime
  end

  def down
  	change_column :travelers, :reset_password_sent_at, :string
  end
end
