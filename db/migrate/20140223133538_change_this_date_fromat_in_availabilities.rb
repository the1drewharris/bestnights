class ChangeThisDateFromatInAvailabilities < ActiveRecord::Migration
  def up
    change_column :availabilities, :this_date, :date
  end

  def down
    change_column :availabilities, :this_date, :datetime
  end
end
