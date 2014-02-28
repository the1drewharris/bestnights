class AddThisDateToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :this_date, :datetime
  end
end
