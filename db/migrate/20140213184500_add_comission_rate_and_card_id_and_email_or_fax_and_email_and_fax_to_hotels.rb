class AddComissionRateAndCardIdAndEmailOrFaxAndEmailAndFaxToHotels < ActiveRecord::Migration
  def change
    add_column :hotels, :comission_rate, :decimal
    add_column :hotels, :card_id, :integer
    add_column :hotels, :email_or_fax, :string
    add_column :hotels, :email, :string
    add_column :hotels, :fax, :string
  end
end
