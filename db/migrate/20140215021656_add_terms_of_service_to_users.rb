class AddTermsOfServiceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :terms_of_service, :integer
  end
end
